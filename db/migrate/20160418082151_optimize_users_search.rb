class OptimizeUsersSearch < ActiveRecord::Migration
  def up
    add_column :users, :tsv_name,     :tsvector
    add_column :users, :tsv_document, :tsvector
    add_column :users, :tsv_query,    :tsvector

    add_index :users, :tsv_name,     using: 'gin'
    add_index :users, :tsv_document, using: 'gin'
    add_index :users, :tsv_query,    using: 'gin'

    execute <<-SQL
      CREATE INDEX index_users_email_trigram ON users USING gist(email gist_trgm_ops);
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION users_tsv_updater() RETURNS trigger AS
      $BODY$
        begin
          new.tsv_name := setweight(to_tsvector('simple', unaccent(coalesce(new.name,''))), 'A');

          new.tsv_document := setweight(to_tsvector('simple', unaccent(coalesce(new.document,''))), 'A');

          new.tsv_query := (
            setweight(to_tsvector('simple', unaccent(coalesce(new.name,''))), 'A') ||
            setweight(to_tsvector('simple', unaccent(coalesce(new.document,''))), 'A')
          );

          return new;
        end
      $BODY$
      LANGUAGE plpgsql;

      CREATE TRIGGER users_tsv_trigger BEFORE INSERT OR UPDATE
      ON users FOR EACH ROW EXECUTE PROCEDURE
      users_tsv_updater();
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE users SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER users_tsv_trigger
      ON users;

      DROP FUNCTION users_tsv_updater()
    SQL

    execute <<-SQL
      DROP INDEX index_users_email_trigram;
    SQL

    remove_index :users, :tsv_name
    remove_index :users, :tsv_document
    remove_index :users, :tsv_query

    remove_column :users, :tsv_name
    remove_column :users, :tsv_document
    remove_column :users, :tsv_query
  end
end
