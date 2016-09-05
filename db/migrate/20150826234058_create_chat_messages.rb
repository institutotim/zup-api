class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.integer :chattable_id
      t.string :chattable_type
      t.integer :kind
      t.integer :user_id
      t.text :text

      t.timestamps
    end
  end
end
