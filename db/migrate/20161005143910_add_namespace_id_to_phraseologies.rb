class AddNamespaceIdToPhraseologies < ActiveRecord::Migration
  def change
    add_column :reports_phraseologies, :namespace_id, :integer
    add_index :reports_phraseologies, :namespace_id
  end
end
