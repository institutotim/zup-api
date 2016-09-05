class CreateCasesLogEntries < ActiveRecord::Migration
  def change
    create_table :cases_log_entries do |t|
      t.references :user,   index: true
      t.string :action, null: false
      t.references :flow,   index: true
      t.references :step,   index: true
      t.references :case,   index: true
      t.integer :before_user_id
      t.integer :after_user_id

      t.timestamps
    end
  end
end
