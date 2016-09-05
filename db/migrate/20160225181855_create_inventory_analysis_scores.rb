class CreateInventoryAnalysisScores < ActiveRecord::Migration
  def change
    create_table :inventory_analysis_scores do |t|
      t.references :inventory_field
      t.references :inventory_analysis

      t.string :content, array: true
      t.decimal :score

      t.timestamps
    end
  end
end
