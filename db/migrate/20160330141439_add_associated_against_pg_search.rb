class AddAssociatedAgainstPgSearch < ActiveRecord::Migration
  def up
    execute <<-'SQL'
      CREATE AGGREGATE array_agg(anyelement) (
        SFUNC=array_append,
        STYPE=anyarray,
        INITCOND='{}'
      )
    SQL
  end

  def down
    execute <<-'SQL'
      DROP FUNCTION unnest(anyarray);
    SQL
  end
end
