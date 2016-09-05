class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user
      t.references :notificable, polymorphic: true

      t.string :title
      t.string :description
      t.boolean :read, default: false
      t.timestamp :read_at

      t.timestamp :created_at, null: false
    end
  end
end
