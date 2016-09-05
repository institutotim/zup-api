require 'app_helper'

describe Reports::ForwardToGroup do
  let(:category)    { create(:reports_category_with_statuses) }
  let(:report)      { create(:reports_item, category: category) }
  let(:setting)     { report.setting }
  let(:user)        { create(:user) }
  let(:group)       { create(:group) }
  let(:other_group) { create(:group) }

  subject { described_class.new(report, user) }

  describe '#forward!' do
    context 'group is a solver' do
      before do
        setting.solver_groups = [group]
        setting.save!

        category.solver_groups = [other_group]
        category.save!
      end

      it 'assigns to that group' do
        subject.forward!(group)
        expect(report.reload.assigned_group).to eq(group)
      end

      it 'should reset the assigned for an user' do
        report.update(assigned_user: create(:user))

        subject.forward!(group)
        expect(report.reload.assigned_user).to be_nil
      end

      context 'report category demands a comment' do
        before do
          setting.update(
            comment_required_when_forwarding: true
          )
        end

        context 'user don\'t type a comment' do
          it 'throws an error' do
            expect do
              subject.forward!(group)
            end.to raise_error
          end
        end

        context 'user does type a comment' do
          let(:message) { 'This is a test' }
          it 'creates the comment' do
            subject.forward!(group, message)
            comment = report.comments.last

            expect(comment.author).to eq(user)
            expect(comment.visibility).to eq(Reports::Comment::INTERNAL)
            expect(comment.message).to eq(message)
          end
        end
      end
    end

    context 'group isn\'t a solver' do
      it 'assigns to that group' do
        expect { subject.forward!(group) }.to raise_error
      end
    end

    context 'group is nil' do
      it 'do not change group' do
        expect{ subject.forward!(nil) }.to_not change{ report.assigned_group }
      end
    end

    context 'perimeter group' do
      let!(:perimeter) { create(:reports_perimeter, group: create(:group)) }

      it 'use perimeter group instead category default group' do
        allow(Reports::Perimeter).to receive(:search) { [perimeter] }

        subject.forward!(group)

        history = report.histories.first

        expect(report.reload.assigned_group).to eq(perimeter.group)
        expect(report.reload.perimeter).to eq(perimeter)
        expect(history.action).to eq("Este relato está localizado dentro do perímetro 'Perimeter'")
        expect(history.kind).to eq('perimeter')
      end
    end

    context 'category perimeter group' do
      let!(:category_perimeter) { create(:reports_category_perimeter, category: category) }
      let!(:perimeter)          { create(:reports_perimeter) }

      before(:each) do
        allow_any_instance_of(Reports::Category).to receive(:find_perimeter) { category_perimeter }
      end

      it 'set group and perimeter' do
        subject.forward!(group)
        history = report.histories.first

        expect(report.reload.assigned_group).to eq(category_perimeter.group)
        expect(report.reload.perimeter).to eq(category_perimeter.perimeter)
        expect(history.action).to eq("Este relato está localizado dentro do perímetro 'Perimeter'")
        expect(history.kind).to eq('perimeter')
      end

      it 'change group when perimeter is already set' do
        allow(setting).to receive(:solver_groups) { [group] }
        allow_any_instance_of(Reports::Item).to receive(:perimeter) { perimeter }

        subject.forward!(group)

        history = report.histories.first

        expect(report.reload.assigned_group).to eq(group)
        expect(history.action).to eq("Relato foi encaminhado para o grupo '#{group.name}'")
        expect(history.kind).to eq('forward')
      end
    end
  end
end
