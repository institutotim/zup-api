module BusinessReports
  class API < Base::API
    resources :business_reports do
      desc 'List all business report'
      paginate per_page: 25
      get do
        authenticate!
        validate_permission!(:view, BusinessReport)

        business_reports = BusinessReport.all

        unless user_permissions.can?(:manage, BusinessReport)
          business_reports = business_reports.where(id: user_permissions.business_reports_visible)
        end

        {
            business_reports: BusinessReport::Entity.represent(
                paginate(business_reports),
                only: return_fields
            )
        }
      end

      desc 'Create a business report'
      params do
        requires :title, type: String
        optional :summary, type: String
        requires :params, type: Hash
      end
      post do
        authenticate!
        validate_permission!(:create, BusinessReport)

        create_params = safe_params.permit(:title, :summary).merge(user: current_user)
        create_params[:params] = safe_params.permit![:params]

        create_params[:namespace_id] = app_namespace_id

        business_report = BusinessReport.create!(create_params)

        {
            business_report: BusinessReport::Entity.represent(
                business_report,
                only: return_fields
            )
        }
      end

      desc 'Update a business report'
      params do
        optional :title, type: String
        optional :summary, type: String
        optional :params, type: Hash
      end
      put ':id' do
        authenticate!

        business_report = BusinessReport.find(params[:id])
        validate_permission!(:edit, business_report)

        update_params = safe_params.permit(:title, :summary)
        update_params[:params] = safe_params.permit![:params]

        business_report.update!(update_params)

        {
            business_report: BusinessReport::Entity.represent(
                business_report,
                only: return_fields
            )
        }
      end

      desc 'Shows a business report'
      get ':id' do
        authenticate!

        business_report = BusinessReport.find(params[:id])
        validate_permission!(:view, business_report)

        { business_report: BusinessReport::Entity.represent(business_report, only: return_fields) }
      end

      desc 'Delete a business report'
      delete ':id' do
        authenticate!

        business_report = BusinessReport.find(params[:id])
        validate_permission!(:delete, business_report)

        business_report.destroy!

        { message: 'Business Report destroyed successfully' }
      end
    end
  end
end
