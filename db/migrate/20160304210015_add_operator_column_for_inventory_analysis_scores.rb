class AddOperatorColumnForInventoryAnalysisScores < ActiveRecord::Migration
  def change
    add_column :inventory_analysis_scores, :operator, :string
  end
end
