module Inventory
  class API < Base::API
    namespace :inventory do
      mount Inventory::Categories::API
      mount Inventory::Items::API
      mount Inventory::Statuses::API
      mount Inventory::Formulas::API
      mount Inventory::FieldOptions::API
      mount Inventory::ItemHistories::API
      mount Inventory::Analyzes::API
    end
  end
end
