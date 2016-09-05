class AddDraftToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :draft, :boolean, default: true
    remove_column :steps, :last_version, :integer
    remove_column :steps, :last_version_id, :integer
  end
end
