class AddNewFeatureFlagForGeolocationLimiting < ActiveRecord::Migration
  def change
    FeatureFlag.create_with(
      status: :enabled
    ).find_or_create_by!(name: 'validate_city_boundaries')
  end
end
