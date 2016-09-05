class FixTriggers < ActiveRecord::Migration
  def change
    triggers = execute "SELECT trigger_name,event_object_table FROM information_schema.triggers WHERE substring(trigger_name from 1 for 6) = 'object'"
    # rubocop:disable all
    triggers.each { |t| execute "DROP TRIGGER #{t['trigger_name']} ON #{t['event_object_table']};" }
    # rubocop:enable all
  end
end
