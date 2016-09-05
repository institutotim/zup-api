require 'csv'

module Inventory
  class ImportFromCSVRow
    attr_reader :category, :fields, :fields_labels, :mapquest

    def initialize(category_id, fields_labels)
      @category = Inventory::Category.find_by!(id: category_id)
      @fields = category.fields.enabled
      @fields_labels = fields_labels
      @mapquest = Mapquest.new
    end

    def import!(row)
      item = Inventory::Item.new
      item.category = category
      item.user = User.first
      array_of_fields = fields.to_a

      row.each_with_index do |column, j|
        next unless column

        field_name = fields_labels[j]
        field = array_of_fields.select { |f| f.label.downcase == field_name.downcase }.first

        if field.nil?
          fail "Campo '#{field_name}' não existe"
        end

        if field.use_options?
          content = field.field_options.where('lower(value) = ?', column.strip.downcase).pluck(:id)
        else
          content = column
        end

        item.data.build(
          field: field,
          content: content
        )
      end

      item.send(:update_position_from_data)
      item.send(:generate_title)

      if item.address.blank? && item.position.present?
        location_data = address_from_geocode(item.position.y, item.position.x)

        update_item_location_data(item, location_data)
      elsif item.position.blank? && item.address.present?
        city = item.represented_data.city
        state = item.represented_data.state

        full_address = "#{item.address}, #{city}"

        position = geocode_from_address(full_address, state, 'BR')

        if position.any?
          item.position = ::Inventory::Item.rgeo_factory.point(
            position[:longitude],
            position[:latitude]
          )

          item.represented_data.latitude = position[:latitude]
          item.represented_data.longitude = position[:longitude]
          item.represented_data.inject_to_data!
        end
      end

      unless item.save(validate: false)
        puts "Ocorreu um erro ao criar o item: #{item.errors.full_messages.inspect}"
      end
    end

    private

    def geocode_from_address(address, state, country)
      mapquest.geoposition(address, state, country)
    rescue
      {}
    end

    def address_from_geocode(latitude, longitude)
      mapquest.address(latitude, longitude)
    rescue
      {}
    end

    def update_item_location_data(item, location_data)
      return if location_data.blank?
      location_fields = fields.location.to_a

      # Address
      address_field = location_fields.select { |f| f.title == 'address' }
      address_item_data = item.data.select { |d| d.inventory_field_id == address_field }.first
      address_item_data.content = location_data[:street]

      # Postal code
      postal_code_field = location_fields.select { |f| f.title == 'postal_code' }
      postal_code_item_data = item.data.select { |d| d.inventory_field_id == postal_code_field }.first
      postal_code_item_data.content = location_data[:postal_code]

      # State
      state_field = location_fields.select { |f| f.title == 'state' }
      state_item_data = item.data.select { |d| d.inventory_field_id == state_field }.first
      state_item_data.content = location_data[:state]

      # City
      city_field = location_fields.select { |f| f.title == 'city' }
      city_item_data = item.data.select { |d| d.inventory_field_id == city_field }.first
      city_item_data.content = location_data[:city]

      # Latitude
      latitude_field = location_fields.select { |f| f.title == 'latitude' }
      latitude_item_data = item.data.select { |d| d.inventory_field_id == latitude_field }.first
      latitude_item_data.content = item.position.y

      # Longitude
      longitude_field = location_fields.select { |f| f.title == 'longitude' }
      longitude_item_data = item.data.select { |d| d.inventory_field_id == longitude_field }.first
      longitude_item_data.content = item.position.x
    end
  end
end
