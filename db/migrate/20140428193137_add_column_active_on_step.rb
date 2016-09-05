class AddColumnActiveOnStep < ActiveRecord::Migration
  def change
    add_column :steps, :active, :boolean, default: true
  end
end
