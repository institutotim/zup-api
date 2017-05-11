require 'spec_helper'

describe Reports::Category do
  let(:namespace) { create(:namespace) }

  context 'statuses' do
    it 'have relation with statuses' do
      category = create(:reports_category_with_statuses)
      expect(category.statuses).to_not be_empty
    end

    it "don't create any other statuses if it already exists" do
    end
  end

  context '#update_statuses!' do
    it "create status if it doesn't exists (by title)" do
      category = create(:reports_category)

      expect(Reports::Status.count).to eq(0)

      category.update_statuses!([{
        'title' => 'Inicio',
        'color' => '#ff0033',
        'initial' => true,
        'final' => true,
        'namespace_id' => namespace.id
      }])

      expect(Reports::Status.count).to eq(1)
      last_created_status = Reports::Status.last
      expect(last_created_status.title).to eq('Inicio')

      last_sc = Reports::StatusCategory.last
      expect(last_sc.color).to eq('#ff0033')
      expect(last_sc.initial).to be_truthy
      expect(last_sc.final).to be_truthy
    end

    context 'when already exists the same title' do
      let(:status) { create(:status) }
      let(:category) { create(:reports_category) }

      it "doesn't create more than one status with same title" do
        category.update_statuses!([{
          'title' => status.title,
          'color' => '#ff0033',
          'initial' => true,
          'final' => true,
          'namespace_id' => namespace.id
        }])

        category.reload
        expect(category.reload.statuses).to include(status)

        expect(Reports::Status.count).to eq(1)
        last_created_status = Reports::Status.last
        expect(last_created_status.id).to eq(status.id)
        expect(last_created_status.title).to eq(status.title)
        expect(last_created_status.color).to eq(status.color)
        expect(last_created_status.initial).to eq(status.initial)
      end

      it "doesn't create more than one status with same title (case insensitive)" do
        category.update_statuses!([{
          'title' => status.title.upcase,
          'color' => '#ff0033',
          'initial' => true,
          'final' => true,
          'namespace_id' => namespace.id
        }])

        category.reload
        expect(category.reload.statuses).to include(status)

        expect(Reports::Status.count).to eq(1)
        last_created_status = Reports::Status.last
        expect(last_created_status.id).to eq(status.id)
        expect(last_created_status.title).to eq(status.title)
        expect(last_created_status.color).to eq(status.color)
        expect(last_created_status.initial).to eq(status.initial)
      end
    end
  end

  context '#find_perimeter' do
    let!(:namespace) { create(:namespace) }
    let!(:category)  { create(:reports_category) }
    let!(:perimeter) { create(:reports_perimeter, :imported) }

    let!(:category_perimeter) do
      create(:reports_category_perimeter,
        category: category,
        perimeter: perimeter,
        namespace: namespace
      )
    end

    it 'find perimeter with latitude and longitude' do
      record = category.find_perimeter(namespace.id, -22.9053121, -43.1956711)
      expect(record).to eq(category_perimeter)
    end
  end

  context 'entity' do
    context 'subcategories' do
      let!(:category) { create(:reports_category) }
      let!(:subcategories) { create_list(:reports_category, 3, parent_category: category) }
      let!(:user) { create(:user) }
      let!(:group) { create(:group) }

      context "user doesn't have permission to see subcategories" do
        before do
          group.permission.update!(reports_items_create: [category.id])
          user.groups = [group]
          user.save
        end

        it do
          represented = Reports::Category::Entity.represent(category,
                                                            only: [subcategories: [:id]],
                                                            display_type: :full,
                                                            user: user).as_json

          expect(represented[:subcategories]).to be_empty
        end
      end

      context 'user does have permission to see subcategories' do
        before do
          group.permission.update!(reports_items_create: [category.id] + subcategories.map(&:id))
          user.groups = [group]
          user.save
        end

        it do
          represented = Reports::Category::Entity.represent(category,
                                                            only: [subcategories: [:id]],
                                                            display_type: :full,
                                                            user: user).as_json

          expect(represented[:subcategories]).to_not be_empty
        end
      end
    end
  end

  describe '#custom_fields_attributes=' do
    let(:category) { create(:reports_category) }

    context 'with new custom fields' do
      let(:custom_fields_params) do
        [
          {
            'title' => 'Test field',
            'multiline' => true
          },
            {
            'title' => 'Test field 2',
            'multiline' => false
          }
        ]
      end

      it 'creates new custom fields and creates associations' do
        category.update(custom_fields_attributes: custom_fields_params)
        expect(category.custom_fields.size).to eq(2)

        category.custom_fields.each_with_index do |custom_field, i|
          expect(custom_field.title).to eq(custom_fields_params[i]['title'])
          expect(custom_field.multiline).to eq(custom_fields_params[i]['multiline'])
        end
      end
    end

    context 'with existing custom fields' do
      let(:custom_fields) do
        create_list(:reports_custom_field, 2)
      end

      let(:custom_fields_params) do
        [
          {
            'id' => custom_fields.first.id,
            'title' => 'Changed title',
            'multiline' => custom_fields.first.multiline
          },
          {
            'title' => 'Test field',
            'multiline' => true
          },
          {
            'id' => custom_fields.last.id,
            'title' => custom_fields.last.title,
            'multiline' => custom_fields.last.multiline,
            '_destroy' => true
          }
        ]
      end

      before do
        category.update!(custom_fields: custom_fields)
      end

      it 'creates the new and updates existing' do
        category.update(custom_fields_attributes: custom_fields_params)
        category.reload

        expect(category.custom_fields.size).to eq(2)

        category.custom_fields.each_with_index do |custom_field, i|
          expect(custom_field.title).to eq(custom_fields_params[i]['title'])
          expect(custom_field.multiline).to eq(custom_fields_params[i]['multiline'])
        end
      end
    end

    context 'with existing custom field, deleting and them adding again' do
      let(:custom_fields_params) do
        [
          {
            'title' => 'Field',
            'multiline' => false
          }
        ]
      end

      it 'should be able to add, remove and add again' do
        category.update(custom_fields_attributes: custom_fields_params)
        expect(category.custom_fields.size).to eq(1)
        created_custom_field_id = category.custom_fields.first.id

        custom_fields_params_for_destroy = [
          custom_fields_params.first.merge(id: created_custom_field_id, _destroy: true)
        ]
        category.update(custom_fields_attributes: custom_fields_params_for_destroy)
        expect(category.custom_fields.size).to eq(0)

        custom_fields_params_again = [
          custom_fields_params.first.merge(id: created_custom_field_id)
        ]
        category.update(custom_fields_attributes: custom_fields_params_again)
        expect(category.custom_fields.size).to eq(1)
      end
    end
  end

  context '#days_for_deletion' do
    let(:category) { build(:reports_category) }

    context 'deleted_at is nil' do
      before { category.deleted_at = nil }
      it 'should return nil' do
        expect(category.days_for_deletion).to be_nil
      end
    end

    context 'deleted_at is present' do
      before { category.deleted_at = 3.days.ago }
      it 'should return the correct number of days' do
        expect(category.days_for_deletion).to eq(27)
      end
    end
  end
end
