class CreateNamespace
  attr_reader :namespace

  def create!(params = {})
    Namespace.transaction do
      @namespace = Namespace.create!(params)
      create_statuses_and_settings
    end
  end

  private

  def create_statuses_and_settings
    CreateStatusesForNamespace.new(namespace).create!
  end
end
