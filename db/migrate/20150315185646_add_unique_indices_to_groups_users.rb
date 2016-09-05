class AddUniqueIndicesToGroupsUsers < ActiveRecord::Migration
  def change
    delete_query = <<-SQL
                        DELETE FROM groups_users gua
                        WHERE gua.ctid <> (SELECT min(gub.ctid)
                                          FROM   groups_users gub
                                          WHERE  gua.user_id = gub.user_id
                                          AND gua.group_id = gub.group_id);
                      SQL

    ActiveRecord::Base.connection.execute(delete_query)
    remove_index :groups_users, [:group_id, :user_id]
    add_index :groups_users, [:group_id, :user_id], unique: true
  end
end
