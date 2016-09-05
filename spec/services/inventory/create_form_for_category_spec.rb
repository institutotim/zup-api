# encoding: utf-8
require 'spec_helper'

describe Inventory::CreateFormForCategory do
  context 'document parsing' do
    let(:category) { create(:inventory_category) }
    let(:form_params) do
      {
        'sections' => [{
          'title' => 'Dados técnicos',
          'permissions' => {},
          'position' => 2,
          'required' => false,
          'fields' => [{
            'title' => 'latitude',
            'kind' => 'text',
            'size' => 'M',
            'permissions' => {},
            'label' => 'Latitude',
            'position' => 0
          }]
        }]
      }
    end

    it "creates the sections if doesn't exists" do
      described_class.new(category, form_params).create!
      expect(category.reload.sections.last.title).to eq('Dados técnicos')
      expect(category.sections.last.id).to_not be_nil
    end

    it 'if the section already exists (by providing ID), updates it data' do
      section = category.sections.create!(title: generate(:name), required: true)
      form_params['sections'].first['id'] = section.id

      described_class.new(category, form_params).create!
      section.reload
      expect(section.title).to eq('Dados técnicos')
      expect(section.position).to eq(2)
      expect(section.required).to eq(false)
    end

    it 'creates the fields for the section' do
      described_class.new(category, form_params).create!
      created_section = category.reload.sections.last
      created_field = created_section.fields.first

      expect(created_field.title).to eq('latitude')
      expect(created_field.id).to_not be_nil
    end

    it 'if the field already exists, updates it' do
      section = category.sections.create(title: generate(:name))
      field = section.fields.create(title: 'anotherfield', position: 10, kind: 'email')
      form_params['sections'].first['fields'].first['id'] = field.id
      form_params['sections'].first['id'] = section.id

      described_class.new(category, form_params).create!
      field.reload
      expect(field.title).to eq('latitude')
      expect(field.position).to eq(0)
      expect(field.kind).to eq('text')
      expect(field.options).to_not be_blank
    end

    context 'creating values for fields' do
      let(:form_params) do
        {
          'sections' => [{
            'title' => 'Dados técnicos',
            'permissions' => {},
            'position' => 2,
            'required' => false,
            'fields' => [{
              'title' => 'latitude',
              'kind' => 'text',
              'size' => 'M',
              'permissions' => {},
              'field_options' => ['Option 1', 'Option 2'],
              'label' => 'Latitude',
              'position' => 0
            }]
          }]
        }
      end

      it 'creates specific field options' do
        described_class.new(category, form_params).create!
        created_section = category.reload.sections.last
        created_field = created_section.fields.first

        expect(created_field.field_options.pluck(:value)).to match_array(['Option 1', 'Option 2'])
      end
    end

    context 'deleting sections' do
      it "delete the section if it has the 'destroy' attribute on it" do
        section = category.sections.create(title: generate(:name))
        form_params['sections'].first['id'] = section.id
        form_params['sections'].first['destroy'] = true

        described_class.new(category, form_params).create!

        section = Inventory::Section.find_by(id: section.id)
        expect(section).to be_disabled
      end
    end

    context 'deleting fields' do
      it "mark field as disable if it has the 'destroy' attribute on it" do
        section = category.sections.create(title: generate(:name))
        field = section.fields.create(title: 'anotherfield', position: 10, kind: 'checkbox')
        form_params['sections'].first['id'] = section.id
        form_params['sections'].first['fields'].first['id'] = field.id
        form_params['sections'].first['fields'].first['destroy'] = true

        described_class.new(category, form_params).create!

        section = Inventory::Section.find_by(id: section.id)
        expect(section).to_not be_nil

        field = Inventory::Field.find_by(id: field.id)
        expect(field).to be_disabled
      end
    end

    context 'updating groups permissions for fields' do
      let(:groups) { create_list(:group, 3) }
      it 'adds permissions to group' do
        form_params['sections'][0]['fields'][0]['permissions'] = {
          'groups_can_view' => groups.map(&:id)
        }

        described_class.new(category, form_params).create!

        created_field = category.sections.last.fields.first
        groups.each do |group|
          expect(group.reload.permission.inventory_fields_can_view).to include(created_field.id)
        end
      end

      it 'removes permissions from group' do
        section = category.sections.create(title: generate(:name))
        field = section.fields.create(title: 'anotherfield', position: 10, kind: 'email')
        form_params['sections'].first['fields'].first['id'] = field.id
        form_params['sections'].first['id'] = section.id

        groups.each do |group|
          group.permission.update(inventory_fields_can_view: [field.id])
        end

        form_params['sections'].last['fields'].first['permissions'] = {
          'groups_can_view' => []
        }

        described_class.new(category, form_params).create!

        groups.each do |group|
          expect(group.reload.permission.inventory_fields_can_view).to_not include(field.id)
        end
      end
    end

    context 'updating groups permissions for sections' do
      let(:groups) { create_list(:group, 3) }

      it 'adds permissions to group' do
        form_params['sections'][0]['permissions'] = {
          'groups_can_view' => groups.map(&:id)
        }

        described_class.new(category, form_params).create!

        created_section = category.sections.last
        groups.each do |group|
          expect(group.permission.reload.inventory_sections_can_view).to include(created_section.id)
        end
      end

      it 'removes permissions from group' do
        section = category.sections.create(title: generate(:name))
        form_params['sections'].first['id'] = section.id

        groups.each do |group|
          group.permission.update(inventory_sections_can_view: [section.id])
        end

        form_params['sections'].first['permissions'] = {
          'groups_can_view' => []
        }

        described_class.new(category, form_params).create!

        groups.each do |group|
          expect(group.reload.permission.inventory_sections_can_view).to_not include(section.id)
        end
      end
    end
  end
end
