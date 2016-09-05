require 'app_helper'

RSpec.describe Reports::Perimeter, type: :model do
  context 'associations' do
    it { should belong_to(:group).with_foreign_key(:solver_group_id) }
    it { should belong_to(:namespace) }
    it { should have_many(:category_perimeters).class_name('Reports::CategoryPerimeter').with_foreign_key(:reports_perimeter_id) }
  end

  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:shp_file) }
    it { should validate_presence_of(:shx_file) }
    it { should validate_presence_of(:namespace) }
  end
end
