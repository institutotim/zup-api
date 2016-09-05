class UseProtocolSequence < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER SEQUENCE protocol_seq OWNED BY reports_items.protocol;
      ALTER TABLE reports_items ALTER COLUMN protocol SET DEFAULT nextval('protocol_seq');
    SQL
  end

  def down
    execute <<-SQL
      ALTER SEQUENCE protocol_seq OWNED BY NONE;
      ALTER TABLE reports_items ALTER COLUMN protocol DROP DEFAULT;
    SQL
  end
end
