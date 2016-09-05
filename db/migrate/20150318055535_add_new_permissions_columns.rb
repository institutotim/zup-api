class AddNewPermissionsColumns < ActiveRecord::Migration
  def change
    add_column :group_permissions, :users_full_access, :boolean, default: false
    add_column :group_permissions, :groups_full_access, :boolean, default: false
    add_column :group_permissions, :reports_full_access, :boolean, default: false
    add_column :group_permissions, :inventories_full_access, :boolean, default: false
    add_column :group_permissions, :inventories_formulas_full_access, :boolean, default: false

    # Array columns
    add_column :group_permissions, :group_edit, :integer, array: true, default: []
    add_column :group_permissions, :group_read_only, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_read_only, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_create, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_edit, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_delete, :integer, array: true, default: []
    add_column :group_permissions, :reports_categories_edit, :integer, array: true, default: []
    add_column :group_permissions, :inventories_items_read_only, :integer, array: true, default: []
    add_column :group_permissions, :inventories_items_create, :integer, array: true, default: []
    add_column :group_permissions, :inventories_items_edit, :integer, array: true, default: []
    add_column :group_permissions, :inventories_items_delete, :integer, array: true, default: []
    add_column :group_permissions, :inventories_categories_edit, :integer, array: true, default: []
    add_column :group_permissions, :inventories_category_manage_triggers, :integer, array: true, default: []
  end
end
