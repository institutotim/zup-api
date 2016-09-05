require 'app_helper'

describe Cases::RelatedEntities do
  describe '#new' do
    context 'when the subject is a report item' do
      let(:object) { create(:reports_item) }

      subject { described_class.new(object) }

      it 'instance is a Cases::RelatedEntities::ForReport' do
        expect(subject.instance.class).to eq(Cases::RelatedEntities::ForReport)
      end
    end
  end
end
