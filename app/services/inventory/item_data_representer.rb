module Inventory
  # TODO: Documentation on this
  # And also make an unit test, please
  class ItemDataRepresenter
    include ActiveModel::Validations

    attr_reader :item, :user

    # Factory creates a new class with
    # specific validations for this item
    # TODO: Improve performance by caching category and fields
    def self.factory(item, user = nil)
      instance_class = dup

      fields = item.category.fields
      fields.each do |field|
        instance_class.send(:attr_accessor, field.title)

        if field.enabled?
          inject_validations(field, instance_class, user)
        end
      end

      instance_class.class_eval do
        def self.model_name
          Inventory::ItemData.model_name
        end
      end

      instance_class.new(item, fields, user)
    end

    # Instance methods
    def initialize(item, fields, user = nil)
      @changes = {} # Store all attributes changes
      @_fields_cache = {}
      @item = item
      @user = user

      fields.each do |field|
        @_fields_cache[field.id] = field
      end

      # Get data from item.data and
      # populate the accessors
      populate_data
    end

    def attributes=(new_attributes)
      new_attributes.each do |field_id, content|
        if field = @_fields_cache[field_id.to_i]
          next if field.disabled?

          set_attribute_content(field, content)
        else
          fail "Inventory field with id #{field_id} doesn't exists!"
        end
      end
    end

    def inject_to_data!
      if valid?
        current_data = item.data

        @_fields_cache.each do |_, field|
          new_content = send("#{field.title}")

          item_data = current_data.select { |i| i.field.id == field.id }.first

          if item_data
            unless %w(attachments images).include?(field.kind) || same_value?(field, new_content, item_data.content)
              @changes[item_data] = {
                old: item_data.content,
                new: new_content
              }
            end

            item_data.content = new_content unless content_is_entity?(new_content)
          else
            item_data = item.data.build(field: field, content: new_content)

            unless %w(attachments images).include?(field.kind)
              @changes[item_data] = {
                new: new_content
              }
            end
          end
        end

        true
      else
        false
      end
    end

    def save!
      item.save!
    end

    def changes
      @changes
    end

    def create_history_entry
      item_data = changes

      if item_data.any?
        Inventory::CreateHistoryEntry.new(item, user)
                                    .create('fields', 'Atualizou os campos', item_data)
      end

      created_images = item.images.select do |image|
        image.id_changed?
      end

      if created_images.any?
        Inventory::CreateHistoryEntry.new(item, user)
                                     .create('images', 'Adicionou novas imagens', created_images)
      end
    end

    private

    def content_is_entity?(content)
      content.is_a?(Array) && content.first.is_a?(Grape::Entity)
    end

    def same_value?(field, new_content, actual_content)
      return true if new_content.nil? && actual_content.nil?

      if new_content.is_a?(Array) && actual_content.is_a?(Array)
        (new_content - actual_content).empty?
      elsif field.use_options? && !new_content.is_a?(Array)
        actual_content = [] unless actual_content
        ([new_content] - actual_content).empty?
      else
        new_content.to_s == actual_content.to_s
      end
    end

    def populate_data
      if item.data.any?
        item.data.each do |item_data|
          set_attribute_content(item_data.field, item_data.converted_content)
        end
      end
    end

    def convert_content_type(field, content)
      convertors = {
        Fixnum => proc do |content|
          content.to_i
        end,
        Float => proc do |content|
          content.to_f
        end
      }

      convertor = convertors[field.content_type]

      if convertor
        unless content.blank?
          convertor.call(content)
        else
          nil
        end
      else
        content
      end
    end

    def set_attribute_content(field, content)
      converted_content = convert_content_type(field, content)

      if self.respond_to?("#{field.title}=")
        send("#{field.title}=", converted_content)
      end
    end

    # Inject validations on the duplicated class
    def self.inject_validations(field, instance_class, user)
      attribute = field.title
      validations = {}
      permissions = UserAbility.for_user(user)

      # If the user doesn't have permission edit this field, let's not
      # validate it.
      if field.required? && permissions.can?(:edit, field)
        validations[:presence] = true
      end

      if field.maximum
        if [Fixnum, Float].include?(field.content_type)
          validations[:numericality] = {
            less_than_or_equal_to: field.maximum
          }

          unless field.required?
            validations[:numericality][:allow_nil] = true
          end
        else
          validations[:length] = {
            maximum: field.maximum
          }

          unless field.required?
            validations[:length][:allow_nil] = true
          end
        end
      end

      if field.minimum
        if [Fixnum, Float].include?(field.content_type)
          validations[:numericality] ||= {}
          validations[:numericality].merge!(greater_than_or_equal_to: field.minimum)

          unless field.required?
            validations[:numericality][:allow_nil] = true
          end
        else
          validations[:length] ||= {}
          validations[:length].merge!(minimum: field.minimum)

          unless field.required?
            validations[:length][:allow_nil] = true
          end
        end
      end

      if validations.any?
        instance_class.send(:validates, field.title, validations)
      end
    end
  end
end
