class AddResolutionStateOnCase < ActiveRecord::Migration
  def change
    add_column :cases, :resolution_state_id, :integer
  end
end
