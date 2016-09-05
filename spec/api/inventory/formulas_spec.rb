require 'spec_helper'

describe Inventory::Formulas::API do
  let(:user) { create(:user) }

  context 'POST /inventory/categories/:id/formulas' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:status) { create(:inventory_status, category: category) }
    let(:field) do
      create(
        :inventory_field,
        section: category.sections.sample
      )
    end
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "inventory_status_id": #{status.id},
          "groups_to_alert": [#{user.group_ids.first}],
          "conditions": [{
            "conditionable_id": #{field.id},
            "conditionable_type": "Inventory::Field",
            "operator": "equal_to",
            "content": "test"
          }]
        }
      JSON
    end

    subject do
      post "/inventory/categories/#{category.id}/formulas", valid_params, auth(user)
    end

    it 'creates a new formula' do
      subject
      expect(response.status).to be_a_requisition_created

      created_formula = category.formulas.last
      expect(created_formula).to_not be_nil
      expect(created_formula.status).to eq(status)
      expect(created_formula.category).to eq(category)
      expect(created_formula.groups_to_alert).to eq([user.group_ids.first])

      created_conditions = created_formula.conditions
      expect(created_conditions).to_not be_empty

      condition = created_conditions.first
      expect(condition.conditionable).to eq(field)
      expect(condition.operator).to eq('equal_to')
      expect(condition.content).to eq('test')
    end

    it 'raise error if something is missing' do
      valid_params.delete('inventory_status_id')

      subject

      expect(response.status).to_not be_an_error
    end

    context 'run for all pre-existing items' do
      before do
        valid_params['run_formula'] = true
      end

      it 'schedules a job for the category' do
        expect do
          subject
        end.to change(ExecuteFormulaForCategory.jobs, :size).by(1)
      end

      it 'schedules the job with the correct params' do
        expect(ExecuteFormulaForCategory).to receive(:perform_async).with(user.id, kind_of(Integer)).and_return(true)
        subject
      end
    end
  end

  context 'PUT /inventory/categories/:category_id/formulas/:id' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:status) { create(:inventory_status, category: category) }
    let(:field) do
      create(
        :inventory_field,
        section: category.sections.sample
      )
    end
    let(:formula) do
      create(:inventory_formula, category: category)
    end

    subject do
      put "/inventory/categories/#{category.id}/formulas/#{formula.id}", valid_params, auth(user)
    end

    context 'updating common data' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "inventory_status_id": #{status.id}
          }
        JSON
      end

      it "updates formula's status" do
        subject

        formula.reload
        expect(response).to be_ok
        expect(formula.status).to eq(status)
      end
    end

    context 'updating existing conditions' do
      let(:formula) do
        create(:inventory_formula, :with_conditions, category: category)
      end

      let(:condition) do
        formula.conditions.sample
      end

      let(:valid_params) do
        {}
      end

      it 'updates existing conditions' do
        valid_params['conditions'] = [{
          id: condition.id,
          operator: 'includes',
          content: ['test', 'others']
        }]

        subject

        formula.reload
        condition.reload

        expect(response).to be_ok
        expect(condition.operator).to eq('includes')
        expect(condition.content).to eq(['test', 'others'])
      end
    end

    context 'destroying existing conditions' do
      let(:formula) do
        create(:inventory_formula, :with_conditions, category: category)
      end

      let(:condition) do
        formula.conditions.sample
      end

      let(:valid_params) do
        {}
      end

      it 'updates existing conditions' do
        valid_params['conditions'] = [{
          id: condition.id,
          _destroy: true
        }]

        subject

        expect(response).to be_ok
        expect(formula.reload.conditions.find_by(id: condition.id)).to be_nil
      end
    end
  end

  describe 'DELETE /inventory/categories/:c_id/formulas/:id' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:formula) { create(:inventory_formula, category: category) }

    subject do
      delete "/inventory/categories/#{category.id}/formulas/#{formula.id}", {}, auth(user)
    end

    it 'destroys the formula' do
      subject

      expect(response).to be_ok
      expect(category.formulas.find_by(id: formula.id)).to be_nil
    end
  end

  context 'alerts' do
    describe 'GET /inventory/categories/:c_id/formulas/:f_id/alerts/:a_id' do
      let(:category) { create(:inventory_category_with_sections) }
      let(:formula) { create(:inventory_formula, :with_history, category: category) }
      let(:alert) { create(:inventory_formula_alert, formula: formula) }

      before do
        formula.histories.update_all(inventory_formula_alert_id: alert.id)
      end

      subject do
        get "/inventory/categories/#{category.id}/formulas/#{formula.id}/alerts/#{alert.id}", {}, auth(user)
      end

      it 'return all affected items' do
        subject

        expect(response).to be_ok
        expect(parsed_body['affected_items']).to_not be_empty
      end
    end
  end
end
