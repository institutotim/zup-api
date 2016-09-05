class AddTriggersVersionsToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :triggers_versions, :hstore, default: {}
  end
end
