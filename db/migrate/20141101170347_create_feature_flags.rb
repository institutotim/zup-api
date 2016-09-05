class CreateFeatureFlags < ActiveRecord::Migration
  def change
    create_table :feature_flags do |t|
      t.string :name
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
