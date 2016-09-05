class CreateGroupsUsersTable < ActiveRecord::Migration
  def change
    create_table :groups_users_tables, if: false do |_t|
      create_table :groups_users, id: false do |t|
        t.references :group
        t.references :user
      end

      add_index :groups_users, [:group_id, :user_id]
      add_index :groups_users, :user_id
    end
  end
end
