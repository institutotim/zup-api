module IntegrationHelper
  def parsed_body
    Oj.load(response.body)
  end

  def entity_of(object, options)
    Oj.load(object.class::Entity.represent(object, options).to_json)
  end
end
