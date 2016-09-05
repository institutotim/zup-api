module Search
  class API < Base::API
    namespace :search do
      mount Search::Groups::API
      mount Search::Users::API

      # Reports
      mount Search::Reports::Items::API
      mount Search::Reports::Notifications::API

      # Inventory
      mount Search::Inventory::Items::API
      mount Search::Inventory::Categories::API
    end
  end
end
