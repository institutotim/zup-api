class ExecuteFormulaForItems
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(user_id, formula_ids, items_ids)
    user = User.find_by(id: user_id)
    formulas = Inventory::Formula.where(id: formula_ids)
    items = Inventory::Item.where(id: items_ids)

    if user && formulas && items
      items.each do |item|
        begin
          service = Inventory::UpdateStatusWithFormulas.new(item, user, formulas)
          service.check_and_update!
        rescue => e
          ErrorHandler.capture_exception(e)
        end
      end
    end
  end
end
