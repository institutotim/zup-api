class AddsNamespaceIdToBiReports < ActiveRecord::Migration
  def change
    add_column :business_reports, :namespace_id, :integer
    add_index :business_reports, :namespace_id
    global_namespace_id = Namespace.where(default: true).first.id
    BusinessReport.where(namespace_id: nil).update_all(namespace_id: global_namespace_id)
  end
end
