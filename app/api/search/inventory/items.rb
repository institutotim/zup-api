module Search::Inventory::Items
  class API < Base::API
    desc 'Search for inventory items'
    paginate per_page: 25
    params do
      optional :inventory_categories_ids, type: String,
               desc: 'Inventory Categories ids, format: "3,5,7"'
      optional :inventory_statuses_ids, type: String,
               desc: 'Inventory status ids, format: "3,5,7"'
      optional :users_ids, type: String,
               desc: 'User ids, format: "3,5,7"'
      optional :address, type: String
      optional :query, type: String, desc: 'Global query including id, address and title'
      optional :title, type: String,
               desc: 'The title of the item'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :created_at, type: Hash,
               desc: 'Limit the period of creation, accepts `begin` and `end`'
      optional :updated_at, type: Hash,
               desc: 'Limit the period of modification date, accepts `begin` and `end`'
      optional :fields, type: Hash,
               desc: 'Filter by fields content'
      optional :sort, type: String,
               desc: 'Values: title, inventory_category_id, created_at, updated_at, id'
      optional :order, type: String,
               desc: 'Values: asc, desc'
      optional :display_type, type: String,
               desc: 'Display type of the listing'
      optional :clusterize, type: String,
               desc: 'Should clusterize the results or not'
      optional :zoom, type: String,
               desc: 'The zoom level for the map'
    end
    get 'inventory/items' do
      search_params = safe_params.permit(
        :address, :title, :query, :sort,
        :order, :clusterize, :zoom,
        created_at: [:begin, :end],
        updated_at: [:begin, :end]
      )

      search_params[:fields] = safe_params[:fields]
      search_params[:position] = safe_params[:position]

      # Pagination
      search_params[:paginator] = method(:paginate)
      search_params[:page] = safe_params[:page]
      search_params[:per_page] = safe_params[:per_page]

      unless safe_params[:inventory_statuses_ids].blank?
        search_params[:statuses] = safe_params[:inventory_statuses_ids].split(',').map do |inventory_status_id|
          Inventory::Status.find(inventory_status_id)
        end
      end

      unless safe_params[:inventory_categories_ids].blank?
        search_params[:categories] = safe_params[:inventory_categories_ids].split(',').map do |inventory_category_id|
          Inventory::Category.find(inventory_category_id)
        end
      end

      unless safe_params[:users_ids].blank?
        search_params[:users] = safe_params[:users_ids].split(',').map do |user_id|
          User.find(user_id)
        end
      end

      results = Inventory::SearchItems.new(current_user, search_params).search

      if safe_params[:clusterize]
        header('Total', results[:total].to_s)

        {
          items: Inventory::Item::Entity.represent(results[:items], only: return_fields, display_type: params[:display_type]),
          clusters: ClusterizeItems::Cluster::Entity.represent(results[:clusters])
        }
      else
        {
          items: Inventory::Item::Entity.represent(results, only: return_fields, display_type: params[:display_type])
        }
      end
    end
  end
end
