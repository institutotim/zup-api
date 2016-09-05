namespace :db do
  task clear_memory_cache: :environment do
    require 'lib/db_utils'
    DbUtils.clear_memory_cache_triggers_funcs
  end
end
