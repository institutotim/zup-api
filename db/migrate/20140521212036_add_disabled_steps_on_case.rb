class AddDisabledStepsOnCase < ActiveRecord::Migration
  def change
    add_column :cases, :disabled_steps, :integer, array: true, default: []
  end
end
