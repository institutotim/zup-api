class AddConductionModeOpenToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :conduction_mode_open, :boolean, default: true
  end
end
