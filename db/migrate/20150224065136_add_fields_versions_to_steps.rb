class AddFieldsVersionsToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :fields_versions, :hstore, default: {}
  end
end
