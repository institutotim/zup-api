class CreateEventLogs < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.references :user
      t.references :namespace

      t.string :url
      t.string :request_method
      t.json :headers, default: {}, null: false
      t.json :request_body, default: {}, null: false

      t.timestamps
    end
  end
end
