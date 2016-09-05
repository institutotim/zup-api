require 'app_helper'

RSpec.describe Reports::CategoryPerimeter, type: :model do
  context 'validations' do
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:group) }
    it { should validate_presence_of(:namespace) }
    it { should validate_presence_of(:perimeter) }
  end

  context 'associations' do
    it { should belong_to(:category).class_name('Reports::Category').with_foreign_key(:reports_category_id) }
    it { should belong_to(:group).with_foreign_key(:solver_group_id) }
    it { should belong_to(:namespace) }
    it { should belong_to(:perimeter).class_name('Reports::Perimeter').with_foreign_key(:reports_perimeter_id) }
  end
end
