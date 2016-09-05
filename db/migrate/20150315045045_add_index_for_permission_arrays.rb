class AddIndexForPermissionArrays < ActiveRecord::Migration
  def change
    add_index :group_permissions, :groups_can_edit,               using: :gin
    add_index :group_permissions, :groups_can_view,               using: :gin
    add_index :group_permissions, :reports_categories_can_edit,   using: :gin
    add_index :group_permissions, :reports_categories_can_view,   using: :gin
    add_index :group_permissions, :inventory_categories_can_edit, using: :gin
    add_index :group_permissions, :inventory_categories_can_view, using: :gin
    add_index :group_permissions, :inventory_sections_can_view,   using: :gin
    add_index :group_permissions, :inventory_sections_can_edit,   using: :gin
    add_index :group_permissions, :inventory_fields_can_edit,     using: :gin
    add_index :group_permissions, :inventory_fields_can_view,     using: :gin
    add_index :group_permissions, :flow_can_view_all_steps,       using: :gin
    add_index :group_permissions, :flow_can_execute_all_steps,    using: :gin
    add_index :group_permissions, :can_view_step,                 using: :gin
    add_index :group_permissions, :can_execute_step,              using: :gin
    add_index :group_permissions, :flow_can_delete_all_cases,     using: :gin
    add_index :group_permissions, :flow_can_delete_own_cases,     using: :gin
  end
end
