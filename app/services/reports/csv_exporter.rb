class Reports::CSVExporter
  attr_reader :category, :user, :filters, :namespace_id

  def initialize(exporter)
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
    ['Protocolo', 'Endereço', 'Referencia', 'Perimetro', 'Descrição', 'Categoria',
      'Data de Cadastro', 'Data de Atualização', 'Situação', 'Grupo Responsável',
      'Usuário Responsável', 'Nome do Solicitante', 'Email do Solicitante',
      'Telefone do Solicitante', 'Total de Comentários ao Solicitante',
      'Total de Observações Internas', 'Latitude', 'Longitude']
  end

  def records
    @records ||= Reports::SearchItems.new(user, filters)
                                     .search
                                     .where(namespace_id: namespace_id)
  end

  def generate_csv(csv, collection)
    collection.find_in_batches do |items|
      items.each do |item|
        csv << [
          item.protocol,
          item.full_address,
          item.reference,
          item.perimeter.try(:title),
          item.description,
          item.category.try(:title),
          I18n.l(item.created_at, format: :long),
          I18n.l(item.updated_at, format: :long),
          item.status.try(:title),
          item.assigned_group.try(:name),
          item.assigned_user.try(:name),
          item.user.try(:name),
          item.user.try(:email),
          item.user.try(:phone),
          item.comments.external.count,
          item.comments.internal.count,
          item.position.try(:y),
          item.position.try(:x)
        ]
      end
    end
  end

  def set_filters
    if users_ids = filters[:users_ids]
      @filters[:user] = User.find(users_ids.split(','))
    end

    if perimeters_ids = filters[:reports_perimeters_ids]
      @filters[:perimeter] = Reports::Perimeter.find(perimeters_ids.split(','))
    end

    if categories_ids = filters[:reports_categories_ids]
      @filters[:category] = Reports::Category.find(categories_ids.split(','))
    end

    if reporters_ids = filters[:reporters_ids]
      @filters[:reporter] = User.find(reporters_ids.split(','))
    end

    if statuses_ids = filters[:statuses_ids]
      @filters[:statuses] = Reports::Status.find(statuses_ids.split(','))
    end
  end
end
