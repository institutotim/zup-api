namespace :inventory_formula_conditions do
  desc 'Generate conditionable type for formulas'
  task :generate_type do
    conditions = Inventory::FormulaCondition.all

    puts "Generate type for #{conditions.count} formula conditions"

    conditions.find_each do |condition|
      condition.conditionable_type = 'Inventory::Field' if condition.conditionable_type.nil?
      condition.save
    end

    puts 'Done!'
  end
end
