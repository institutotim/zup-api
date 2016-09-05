require 'app_helper'
require 'return_fields_params'

describe ReturnFieldsParams do
  let(:param) do
    'id,name,user.name,user.groups.id,user.groups.name'
  end

  subject { described_class.new(param) }

  describe '#to_array' do
    it 'converts correctly to hash' do
      expect(subject.to_array).to match(
        [
          :id, :name,
          { user: [:name, { groups: [:id, :name] }] }
        ]
      )
    end
  end
end
