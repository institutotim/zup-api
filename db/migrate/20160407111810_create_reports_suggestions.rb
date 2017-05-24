class CreateReportsSuggestions < ActiveRecord::Migration
  def change
    create_table :reports_suggestions do |t|
      t.integer :reports_category_id
      t.integer :reports_item_id
      t.integer :reports_items_ids, array: true, default: []
      t.integer :status, default: 0

      t.string :address
    end

    add_index :reports_suggestions, :reports_category_id
    add_index :reports_suggestions, :reports_item_id
    add_index :reports_suggestions, :reports_items_ids, using: :gin
    add_index :reports_suggestions, :status
  end
end
