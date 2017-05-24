class CreatePhraseologies < ActiveRecord::Migration
  def change
    create_table :reports_phraseologies do |t|
      t.integer :reports_category_id, index: true
      t.string :title
      t.text :description
    end
  end
end
