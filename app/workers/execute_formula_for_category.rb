class ExecuteFormulaForCategory
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(user_id, formula_id)
    user = User.find_by(id: user_id)
    formula = Inventory::Formula.find_by(id: formula_id)

    if user && formula
      # Get all inventory items and check the formula against it
      items = formula.category.items
                     .where.not(inventory_status_id: formula.inventory_status_id)

      items.find_in_batches(batch_size: 100) do |group|
        ExecuteFormulaForItems.perform_async(user.id, formula.id, group.map(&:id))
      end
    end
  end
end
