class AddDraftToTriggers < ActiveRecord::Migration
  def change
    add_column :triggers, :trigger_conditions_versions, :hstore, default: {}
    add_column :triggers, :draft,           :boolean, default: true
    remove_column :triggers, :last_version,    :integer
    remove_column :triggers, :last_version_id, :integer
  end
end
