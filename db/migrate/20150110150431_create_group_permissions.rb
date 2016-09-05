class CreateGroupPermissions < ActiveRecord::Migration
  def change
    create_table :group_permissions do |t|
      t.belongs_to :group, index: true

      # Boolean permissions
      t.boolean :manage_flows, default: false
      t.boolean :manage_users, default: false
      t.boolean :manage_inventory_categories, default: false
      t.boolean :manage_inventory_items, default: false
      t.boolean :manage_groups, default: false
      t.boolean :manage_reports_categories, default: false
      t.boolean :manage_reports, default: false
      t.boolean :manage_inventory_formulas, default: false
      t.boolean :manage_config, default: false
      t.boolean :delete_inventory_items, default: false
      t.boolean :delete_reports, default: false
      t.boolean :edit_inventory_items, default: false
      t.boolean :edit_reports, default: false
      t.boolean :view_categories, default: false
      t.boolean :view_sections, default: false
      t.boolean :edit_reports, default: false
      t.boolean :delete_reports, default: false
      t.boolean :panel_access, default: false
      t.boolean :flow_can_delete_own_cases, default: false
      t.boolean :flow_can_delete_all_cases, default: false

      # Array permissions
      t.integer :groups_can_edit, array: true, default: []
      t.integer :groups_can_view, array: true, default: []
      t.integer :reports_categories_can_edit, array: true, default: []
      t.integer :reports_categories_can_view, array: true, default: []
      t.integer :inventory_categories_can_edit, array: true, default: []
      t.integer :inventory_categories_can_view, array: true, default: []
      t.integer :inventory_sections_can_view, array: true, default: []
      t.integer :inventory_sections_can_edit, array: true, default: []
      t.integer :inventory_fields_can_edit, array: true, default: []
      t.integer :inventory_fields_can_view, array: true, default: []
      t.integer :flow_can_view_all_steps, array: true, default: []
      t.integer :flow_can_execute_all_steps, array: true, default: []
      t.integer :can_view_step, array: true, default: []
      t.integer :can_execute_step, array: true, default: []

      t.timestamps
    end
  end
end
