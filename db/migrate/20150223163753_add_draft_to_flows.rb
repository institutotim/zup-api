class AddDraftToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :draft, :boolean, default: true
    remove_column :flows, :last_version, :integer
    remove_column :flows, :last_version_id, :integer
  end
end
