class UseInventoryItemSequence < ActiveRecord::Migration
  def up
    execute <<-SQL
      SELECT setval('inventory_item_sequence_seq', (SELECT MAX(sequence) FROM inventory_items));
      ALTER SEQUENCE inventory_item_sequence_seq OWNED BY inventory_items.sequence;
      ALTER TABLE inventory_items ALTER COLUMN sequence SET DEFAULT nextval('inventory_item_sequence_seq');
    SQL
  end

  def down
    execute <<-SQL
      ALTER SEQUENCE inventory_item_sequence_seq OWNED BY NONE;
      ALTER TABLE inventory_items ALTER COLUMN sequence DROP DEFAULT;
    SQL
  end
end
