module Exports
  class API < Base::API
    namespace 'exports' do
      desc 'Create a new export'
      params do
        requires :kind, type: String,
          desc: 'Specify if is a report or an inventory',
          values: ['report', 'inventory']
        optional :inventory_category_id, type: Integer,
          desc: 'Id of inventory category '
        optional :filters, type: Hash,
          desc: 'Define the filters that export will use'
      end
      post do
        authenticate!

        export_params = safe_params.permit(:kind, :inventory_category_id)
        export_params[:filters] = safe_params.fetch(:filters) { {} }
        export_params[:namespace_id] = app_namespace_id

        Export.transaction do
          export = current_user.exports.new(export_params)

          if export.inventory?
            validate_permission!(:export_inventories, export)
          else
            validate_permission!(:export_reports, export)
          end

          export.save!

          ExportToCSV.perform_async(export.id)

          {
            export: Export::Entity.represent(export)
          }
        end
      end

      desc 'Destroy an export'
      delete ':id' do
        authenticate!

        export = current_user.exports.find(params[:id])

        if export.destroy
          status 204
        else
          status 422
        end
      end

      desc 'List all exports'
      params do
        optional :sort,  type: String, values: ['created_at', 'status'], default: 'created_at',
          desc: 'The field to sort the exports'
        optional :order, type: String, values: ['desc', 'asc'], default: 'desc',
          desc: 'The order, can be `desc` or `asc`'
      end
      get do
        authenticate!

        exports = current_user.exports.includes(:inventory_category)
        exports = exports.order(params[:sort] => params[:order].to_sym)

        {
          exports: Export::Entity.represent(paginate(exports), only: return_fields)
        }
      end
    end
  end
end
