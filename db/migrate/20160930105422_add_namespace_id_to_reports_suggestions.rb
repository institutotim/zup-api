class AddNamespaceIdToReportsSuggestions < ActiveRecord::Migration
  def change
    add_column :reports_suggestions, :namespace_id, :integer
    add_index :reports_suggestions, :namespace_id
  end
end
