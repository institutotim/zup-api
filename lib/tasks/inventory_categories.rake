namespace :inventory_categories do
  task unlock: :environment do
    Inventory::Category.locked.each do |category|
      Inventory::CategoryLocking.new(category).unlock_if_expired!
    end
  end
end
