class CreateReportsCategorySettings < ActiveRecord::Migration
  def change
    create_table :reports_category_settings do |t|
      t.references :reports_category, index: true
      t.references :namespace, index: true

      t.boolean :resolution_time_enabled, default: false, null: false
      t.integer :resolution_time
      t.boolean :private_resolution_time, default: false, null: false
      t.integer :user_response_time
      t.boolean :allows_arbitrary_position, default: false, null: false
      t.boolean :confidential, default: false, null: false
      t.integer :default_solver_group_id
      t.integer :solver_groups_ids, array: true, default: []
      t.boolean :comment_required_when_forwarding, default: false, null: false
      t.boolean :comment_required_when_updating_status, default: false, null: false
      t.boolean :notifications, default: false, null: false
      t.boolean :ordered_notifications, default: false, null: false
      t.boolean :perimeters, default: false, null: false
      t.integer :flow_id
      t.integer :priority, default: 0, null: false
    end
  end
end
