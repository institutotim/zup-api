class AddInstitutionSkypeBirthdateCommercialPhoneToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :skype
      t.string :institution
      t.string :position
      t.string :commercial_phone
      t.date :birthdate
    end
  end
end
