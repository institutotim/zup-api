class CreateCaseAttachments < ActiveRecord::Migration
  def change
    create_table :case_attachments do |t|
      t.string :attachment
      t.references :case, index: true

      t.timestamps
    end
  end
end
