class NormalizeFeatureFlags < ActiveRecord::Migration
  def change
    FeatureFlag.where(status: nil).each do |ff|
      ff.update(status: :disabled)
    end
  end
end
