class AddDraftToFields < ActiveRecord::Migration
  def change
    add_column :fields, :draft, :boolean, default: true
    remove_column :fields, :last_version, :integer
    remove_column :fields, :last_version_id, :integer
  end
end
