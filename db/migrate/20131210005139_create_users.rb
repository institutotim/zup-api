class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :encrypted_password
      t.string :salt
      t.string :reset_password_token

      t.string :name
      t.string :email
      t.string :phone
      t.string :document
      t.string :address
      t.string :address_additional
      t.string :postal_code
      t.string :district

      t.datetime :password_resetted_at
      t.timestamps
    end

    add_index :users, :username
  end
end
