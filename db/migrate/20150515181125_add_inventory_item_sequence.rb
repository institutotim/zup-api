class AddInventoryItemSequence < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SEQUENCE inventory_item_sequence_seq;
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE inventory_item_sequence_seq;
    SQL
  end
end
