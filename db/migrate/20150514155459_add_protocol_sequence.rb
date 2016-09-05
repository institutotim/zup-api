class AddProtocolSequence < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SEQUENCE protocol_seq;
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE protocol_seq;
    SQL
  end
end
