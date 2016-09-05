class AddColumnOriginalCaseIdOnCases < ActiveRecord::Migration
  def change
    add_column :cases, :original_case_id, :integer
  end
end
