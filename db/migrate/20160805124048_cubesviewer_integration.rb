class CubesviewerIntegration < ActiveRecord::Migration
  def up
    execute 'DROP TABLE IF EXISTS business_report_views'
    execute 'DROP TABLE IF EXISTS business_report_and_views'
    add_column :business_reports, :params, :json
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
