module DbUtils
  def self.clear_memory_cache_triggers_funcs
    puts 'Removing triggers and functions left over by Memory Cache...'

    ActiveRecord::Base.logger = nil
    ActiveRecord::Base.connection.execute "DO $$
DECLARE trig record;
DECLARE func record;
BEGIN
    EXECUTE 'SELECT pg_advisory_lock(9)';
    FOR trig IN SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE trigger_name LIKE 'object_post_insert_notify%'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || trig.trigger_name || ' ON ' || trig.event_object_table || ' CASCADE';
    END LOOP;
    FOR func IN SELECT * FROM pg_proc WHERE proname LIKE 'object_notify%'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || func.proname || '()';
    END LOOP;
    EXECUTE 'SELECT pg_advisory_unlock(9)';
END$$;"

    redis = Redis.new url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/zup'
    redis.keys('memory-cache*').each { |key| redis.del(key) }
  end
end
