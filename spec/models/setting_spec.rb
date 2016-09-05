require 'app_helper'

describe Setting do
  describe '#value=' do
    context 'when the value is an array' do
      it 'marks kind as array' do
        setting = Setting.create(name: 'Test', value: ['1', '2', '3'])
        expect(setting).to be_array
        expect(setting.value).to eq(['1', '2', '3'])
      end

      context 'when the values of the array is json' do
        it 'returns all values as json' do
          data = [
            { 'id' => 1, 'foo' => 'bar' },
            { 'id' => nil, 'foo' => 'bar' }
          ]

          setting = Setting.create(
            name: 'Test',
            value: data
          )

          expect(setting).to be_json
          setting.value.each_with_index do |hash, i|
            expect(hash).to match(data[i])
          end
        end
      end
    end

    context 'when the value is a string' do
      it 'marks kind as string' do
        setting = Setting.create(name: 'Test', value: 'test')
        expect(setting).to be_string
        expect(setting.value).to eq('test')
      end
    end

    context 'when the value is a json' do
      it 'marks kind as json' do
        setting = Setting.create(name: 'Test', value: { 'id' => 1, 'test' => '2' })
        expect(setting).to be_json
        expect(setting.value).to eq('id' => 1, 'test' => '2')
      end
    end
  end
end
