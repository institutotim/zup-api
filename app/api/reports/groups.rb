module Reports::Groups
  class API < Base::API
    desc 'Return all reports grouped'
    params do
      requires :reports_item_id, type: Integer,
        desc: "The report's ID"
    end
    get '/items/:reports_item_id/group' do
      report = Reports::Item.find(safe_params[:reports_item_id])

      validate_permission!(:view, report)

      reports = report.grouped_reports

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: 'full'
        )
      }
    end

    desc 'Group reports items'
    params do
      requires :reports_ids, type: String,
        desc: 'The IDs of the reports items to be grouped. Ex: 1,2,3'
    end
    post '/group' do
      authenticate!
      validate_permission!(:group, Reports::Item)

      reports = Reports::Item.where(
        id: safe_params[:reports_ids].split(','),
        namespace_id: app_namespace_id
      )

      Reports::GroupItems.new(current_user, reports).group!

      {
        message: 'Relatos agrupados com sucesso'
      }
    end

    desc 'Ungroup reports items'
    params do
      requires :reports_ids, type: String,
        desc: 'The IDs of the reports items to be ungrouped. Ex: 1,2,3'
    end
    delete '/ungroup' do
      authenticate!
      validate_permission!(:group, Reports::Item)

      reports = Reports::Item.where(
        id: safe_params[:reports_ids].split(','),
        namespace_id: app_namespace_id
      )

      Reports::GroupItems.new(current_user, reports).ungroup!

      {
        message: 'Relatos desagrupados com sucesso'
      }
    end
  end
end
