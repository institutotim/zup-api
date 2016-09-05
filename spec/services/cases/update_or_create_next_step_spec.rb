require 'app_helper'

describe Cases::UpdateOrCreateNextStep do
  let(:kase) { create(:case) }
  let(:user) { create(:user) }
  let(:case_step) { create(:case_step, kase: kase) }

  describe '#update!' do
    context 'validating required params' do
      context 'with all valid params' do
        it "doesn't raise exception" do
          expect do
            described_class.new(
              kase: kase,
              case_step: case_step,
              user: user,
              fields_params: [],
              params: {}
            ).update!
          end.to_not raise_exception
        end
      end

      context 'with missing `user` param' do
        it 'raises an exception' do
          expect do
            described_class.new(
              kase: kase,
              case_step: case_step,
              fields_params: [],
              params: {}
            ).update!
          end.to raise_exception('Parameter(s) `user` missing')
        end
      end
    end

    context 'checking if entities were uptated' do
      let(:params) { Hash.new }
      subject do
        described_class.new(
          kase: kase,
          user: user,
          case_step: case_step,
          params: params,
          fields_params: []
        )
      end

      before do
        subject.update!
      end

      it 'updates the `updated_by` with user' do
        case_step.reload
        expect(case_step.updated_by).to eq(user)
      end
    end
  end

  describe '#create!' do
    context 'creating with valid parameters' do
      let(:new_step) { create(:step_type_form, flow: kase.initial_flow) }
      let(:fields_params) do
        new_step.flow.fields.map do |f|
          {
            field_id: f.id,
            value: 'Test'
          }
        end
      end

      subject do
        described_class.new(
          kase: kase,
          user: user,
          step: new_step,
          params: {},
          fields_params: fields_params
        )
      end

      before do
        new_step.update!(draft: true)
        kase.initial_flow.update!(draft: true)
        new_step.flow.publish(user)
        kase.update!(flow_version: kase.initial_flow.versions.last.id)
      end

      it "doesn't raise error" do
        expect do
          subject.create!
        end.to_not raise_error
      end

      it 'creates the case_step for the case' do
        subject.create!
        kase.reload
        expect(kase.case_steps.find_by(step_id: new_step.id)).to be_present
      end
    end
  end
end
