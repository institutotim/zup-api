class Inventory::UpdateStatusWithFormulas
  attr_reader :item, :user, :formulas

  def initialize(item, user, formulas = nil)
    @item = item
    @user = user
    @formulas = formulas
  end

  # Updates an item status
  def check_and_update!
    @formulas ||= retrieve_formulas

    formulas.each do |formula|
      validator = Inventory::FormulaValidator.new(item, formula)

      if validator.valid?
        item.update(status: formula.status)

        alert = formula.alerts.create(groups_alerted: formula.groups_to_alert)
        formula.histories.create(item: item, alert: alert)

        Inventory::CreateHistoryEntry.new(item, user)
                                     .create('status',
                                             'Fórmula mudou o status do item.',
                                             formula)
      end
    end
  end

  private

  def retrieve_formulas
    if item && item.category
      item.category.formulas
    end
  end
end
