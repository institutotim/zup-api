module Search::Inventory::Categories
  class API < Base::API
    desc 'Search for inventory categories'
    paginate per_page: 25
    params do
      optional :title, type: String, desc: 'The name of the inventory category to search for'
    end
    get 'inventory/categories' do
      authenticate!

      categories = Inventory::Category

      unless user_permissions.can?(:manage, Inventory::Category)
        categories = categories.where(id: user_permissions.inventory_categories_visible)
      end

      categories = categories.search_by_title(safe_params[:title]) if safe_params[:title]
      categories = paginate(categories)

      {
        categories: Inventory::Category::Entity.represent(categories, only: return_fields, user: current_user)
      }
    end
  end
end
