class Inventory::CSVExporter
  attr_reader :category, :user, :filters, :namespace_id

  def initialize(exporter)
    @category     = exporter.inventory_category
    @user         = exporter.user
    @filters      = exporter.filters.symbolize_keys
    @namespace_id = exporter.namespace_id

    set_filters
  end

  def to_csv(options = {})
    options.merge!(headers: headers)

    exporter = ::CSVExporter.new(records)

    exporter.to_csv(options) do |csv, collection|
      generate_csv(csv, collection)
    end
  end

  private

  def headers
    @headers ||=
      ['Categoria', 'ID', 'Numero', 'Data de Cadastro', 'Data de Atualização',
        'Nome do Criador', 'Email do Criador', 'Nome do Atualizador',
        'Email do Atualizador', 'Situação'] +
        fields.map { |field| "#{field.section_title} - #{field.label}" }
  end

  def fields
    @fields ||=
      Inventory::Field.select('inventory_fields.id AS id')
        .select('inventory_fields.title AS title')
        .select('inventory_fields.position AS position')
        .select('inventory_fields.kind AS kind')
        .select('inventory_fields.options AS options')
        .select('inventory_sections.id AS section_id')
        .select('inventory_sections.title AS section_title')
        .select('inventory_sections.position AS section_position')
        .joins(:section)
        .joins('LEFT OUTER JOIN inventory_item_data ON inventory_item_data.inventory_field_id = inventory_fields.id')
        .where('inventory_sections.inventory_category_id = ?', category.id)
        .where('inventory_fields.kind NOT IN (?)', %w(images attachments))
        .group('inventory_fields.id, inventory_fields.title, inventory_fields.position')
        .group('inventory_fields.kind, inventory_fields.options')
        .group('inventory_sections.id, inventory_sections.title, inventory_sections.position')
        .order('inventory_sections.position ASC, inventory_fields.position ASC')
        .order('inventory_sections.id ASC, inventory_fields.id ASC')
        .having('COUNT(inventory_item_data.id) > 0 OR inventory_fields.disabled = false')
  end

  def records
    @records ||= Inventory::SearchItems.new(user, filters)
                                       .search
                                       .where(namespace_id: namespace_id)
                                       .includes(:status)
  end

  def generate_csv(csv, collection)
    collection.find_in_batches do |items|
      items.each do |item|
        data    = item.data.includes(:field)
        status  = item.status
        history = item.histories.last
        updater = history.try(:user)

        row = [
          category.title,
          item.id,
          item.sequence,
          I18n.l(item.created_at, format: :long),
          I18n.l(item.updated_at, format: :long),
          item.user.name,
          item.user.email,
          updater.try(:name),
          updater.try(:email),
          status.try(:title)
        ]

        row += fields.map do |field|
          item_data = data.select { |d| d.inventory_field_id == field.id }.first
          represented_data(item_data)
        end

        csv << row
      end
    end
  end

  def represented_data(data = nil)
    return nil unless data

    if data.field.use_options?
      if data.selected_options.blank?
        nil
      else
        data.selected_options.map(&:value).join('; ')
      end
    else
      data.content
    end
  end

  def set_filters
    @filters[:categories] = [category]

    if statuses_ids = filters[:inventory_statuses_ids]
      @filters[:statuses] = Inventory::Status.find(statuses_ids.split(',')).to_a
    end

    if users_ids = filters[:users_ids]
      @filters[:users] = User.find(users_ids.split(',')).to_a
    end
  end
end
