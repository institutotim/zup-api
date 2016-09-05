require 'spec_helper'

describe Reports::NotifyUser do
  let!(:item) { create(:reports_item) }
  let(:user)  { item.user }

  let!(:status) do
    create(
      :status,
      initial: false,
      final: false,
      title: 'Relato em andamento'
    )
  end

  let!(:status_category) do
    create(:reports_status_category, status: status, category: item.category)
  end

  before do
    user.groups = Group.guest
    user.save!
  end

  subject { described_class.new(item) }

  describe '#should_user_receive_status_notification?' do
    context "status isn't private" do
      it 'returns true' do
        expect(
          subject.should_user_receive_status_notification?(status)
        ).to be_truthy
      end
    end

    context 'status is private' do
      before do
        status.status_categories.find_by(
          category: item.category
        ).update(private: true)
      end

      it 'returns false' do
        expect(
          subject.should_user_receive_status_notification?(status)
        ).to be_falsy
      end
    end

    context 'user has permissions to manage reports items' do
      let(:group) { create(:group) }

      before do
        group.permission.update(manage_reports: true)
        item.user.groups = [group]
        item.user.save!
      end

      it 'returns true' do
        expect(
          subject.should_user_receive_status_notification?(status)
        ).to be_truthy
      end
    end
  end

  describe '#notify_new_comment!' do
    context 'is a public comment' do
      let(:comment) { create(:reports_comment, item: item) }

      it 'sends the email' do
        allow(UserMailer).to receive(:delay).and_return(UserMailer)

        subject.notify_new_comment!(comment)
        expect(UserMailer).to have_received(:delay)
      end
    end

    context 'is an internal comment' do
      let(:comment) { create(:reports_comment, :internal, item: item) }

      it 'sends the email' do
        allow(UserMailer).to receive(:delay).and_return(UserMailer)

        subject.notify_new_comment!(comment)
        expect(UserMailer).to_not have_received(:delay)
      end
    end
  end
end
