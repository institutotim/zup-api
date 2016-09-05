module Inventory::Statuses
  class API < Base::API
    helpers do
      def load_category
        Inventory::Category.find(params[:category_id])
      end
    end

    namespace 'categories/:category_id/statuses' do
      desc "Return all category's statuses"
      get do
        validate_permission!(:view, Inventory::Category)

        category = load_category
        statuses = category.statuses

        {
          statuses: Inventory::Status::Entity.represent(statuses)
        }
      end

      desc 'Create a status for the category'
      params do
        requires :title, type: String, desc: 'The status title (maximum 160)'
        requires :color, type: String, desc: 'Color in hexadecimal format'
      end
      post do
        validate_permission!(:edit, Inventory::Category)

        status_params = safe_params.permit(:title, :color)

        category = load_category
        status = Inventory::Status.new(status_params)
        status.category = category
        status.save!

        {
          status: Inventory::Status::Entity.represent(status)
        }
      end

      desc 'Update the category status'
      params do
        optional :title, type: String, desc: 'The status title (maximum 160)'
        optional :color, type: String, desc: 'Color in hexadecimal format'
      end
      put ':id' do
        validate_permission!(:edit, Inventory::Category)

        status_params = safe_params.permit(:title, :color)

        category = load_category
        status = category.statuses.find(params[:id])
        status.update!(status_params)

        {
          status: Inventory::Status::Entity.represent(status)
        }
      end

      desc 'Remove an category status'
      delete ':id' do
        validate_permission!(:edit, Inventory::Category)

        category = load_category
        status = category.statuses.find(params[:id])
        status.destroy!
      end
    end
  end
end
