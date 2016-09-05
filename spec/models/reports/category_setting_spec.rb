require 'app_helper'

RSpec.describe Reports::CategorySetting, type: :model do
  describe 'associations' do
    it { should belong_to(:category).class_name('Reports::Category').with_foreign_key(:reports_category_id) }
    it { should belong_to(:namespace) }
  end

  describe 'validations' do
    subject { build(:reports_category_setting, resolution_time_enabled: true) }

    it { should validate_presence_of(:reports_category_id) }
    it { should validate_presence_of(:namespace_id) }
    it { should validate_presence_of(:resolution_time) }

    it { should validate_uniqueness_of(:namespace_id).scoped_to(:reports_category_id) }
  end
end
