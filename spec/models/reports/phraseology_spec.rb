require 'app_helper'

RSpec.describe Reports::Phraseology, type: :model do
  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
  end

  context 'associations' do
    it { should belong_to(:category).class_name('Reports::Category').with_foreign_key(:reports_category_id) }
  end
end
