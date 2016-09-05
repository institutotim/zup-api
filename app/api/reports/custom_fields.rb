module Reports::CustomFields
  class API < Base::API
    namespace 'custom_fields' do
      desc 'Get all custom fields'
      params do
        optional :title, String, desc: 'Autocompletes by title'
      end
      get do
        authenticate!

        if params[:title]
          custom_fields = Reports::CustomField.search_by_title(params[:title])
        else
          custom_fields = Reports::CustomField.all
        end

        {
          custom_fields: \
            Reports::CustomField::Entity.represent(custom_fields)
        }
      end
    end
  end
end
