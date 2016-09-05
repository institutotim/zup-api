require 'app_helper'

describe CaseStep do
  let(:kase) { create(:case) }
  let(:case_step) { create(:case_step, kase: kase) }
  let(:user) { create(:user) }

  context 'when case_step is created' do
    it 'generates a notification for the user' do
      TestAfterCommit.with_commits(true) do
        Sidekiq::Testing.inline! do
          create(:case_step, kase: kase, responsible_user: user)

          expect(Notification.count).to eq(1)
          expect(Notification.last.notificable).to eq(kase)
        end
      end
    end

    context 'case has a report associated with it' do
      let(:report) { create(:reports_item) }

      before do
        report.update!(case_id: kase.id)
      end

      it 'updates the report `assigned_user_id` to the same `responsible_user_id`' do
        TestAfterCommit.with_commits(true) do
          create(:case_step, kase: kase, responsible_user: user)
          expect(report.reload.assigned_user).to eq(user)
        end
      end
    end
  end

  context 'if responsible_user changes' do
    it 'generates a notification' do
      TestAfterCommit.with_commits(true) do
        Sidekiq::Testing.inline! do
          case_step.update!(responsible_user: user)

          expect(Notification.count).to eq(1)
          expect(Notification.last.notificable).to eq(kase)
        end
      end
    end

    it 'updates the case responsible user' do
      TestAfterCommit.with_commits(true) do
        Sidekiq::Testing.inline! do
          case_step.update!(responsible_user: user)
          kase.reload
          expect(kase.responsible_user).to eq(user.id)
        end
      end
    end

    context 'case has a report associated with it' do
      let(:report) { create(:reports_item) }

      before do
        report.update!(case_id: case_step.case_id)
      end

      it 'updates the report `assigned_user_id` to the same `responsible_user_id`' do
        TestAfterCommit.with_commits(true) do
          case_step.update!(responsible_user: user)

          report.reload
          expect(report.assigned_user).to eq(user)
        end
      end
    end
  end
end
