class AddStepsVersionsToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :steps_versions, :hstore, default: {}
  end
end
