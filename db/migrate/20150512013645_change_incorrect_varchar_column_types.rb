class ChangeIncorrectVarcharColumnTypes < ActiveRecord::Migration
  def up
    change_column :inventory_item_data_histories, :new_content, :text
  end

  def down
    change_column :inventory_item_data_histories, :new_content, :string
  end
end
