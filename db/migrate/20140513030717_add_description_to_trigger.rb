class AddDescriptionToTrigger < ActiveRecord::Migration
  def change
    add_column :triggers, :description, :text
  end
end
