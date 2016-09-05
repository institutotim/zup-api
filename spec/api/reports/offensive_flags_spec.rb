require 'app_helper'

describe Reports::OffensiveFlags::API do
  let(:item) { create(:reports_item) }
  let(:user) { create(:user) }

  describe 'PUT /reports/items/:id/offensive' do
    subject { put "/reports/items/#{item.id}/offensive", nil, auth(user) }

    it 'creates offensive flag for the report item' do
      subject

      expect(
        Reports::OffensiveFlag.where(reports_item_id: item.id).count
      ).to be > 0
    end

    context 'user already reported item' do
      before do
        Reports::FlagItemAsOffensive.new(user, item).flag!
      end

      it 'creates offensive flag for the report item' do
        subject

        expect(response.status).to eq(400)
        expect(parsed_body['type']).to eq('model_validation')
        expect(parsed_body['error']).to eq(I18n.t(:'reports.items.offensive.error.already_reported'))
      end
    end

    context 'user reached limit of report per hour' do
      let(:other_item) { create(:reports_item) }

      before do
        Reports::FlagItemAsOffensive::MAXIMUM_REPORTS_BY_HOUR_PER_USER = 1
        Reports::FlagItemAsOffensive.new(user, other_item).flag!
      end

      it 'creates offensive flag for the report item' do
        subject

        expect(response.status).to eq(400)
        expect(parsed_body['type']).to eq('model_validation')
        expect(parsed_body['error']).to eq(I18n.t(:'reports.items.offensive.error.limit_reached'))
      end
    end
  end

  describe 'DELETE /reports/items/:id/offensive' do
    subject { delete "/reports/items/#{item.id}/offensive", nil, auth(user) }

    before do
      create(:reports_offensive_flag, item: item)
      item.update!(offensive: true)
    end

    it 'removes all flags' do
      subject

      expect(
        Reports::OffensiveFlag.where(reports_item_id: item.id).count
      ).to eq(0)
    end

    it 'removes the offensive flag form the report item' do
      subject
      item.reload

      expect(item).to_not be_offensive
    end

    context "user doesn't have permission to edit report" do
      before do
        permissions = double(UserAbility, namespaces_visible: [user.namespace_id])
        allow(permissions).to receive(:can?).with(:edit, item).and_return(false)
        allow(permissions).to receive(:can?).with(:manage, Namespace).and_return(false)
        allow(UserAbility).to receive(:new).with(user).and_return(permissions)
      end

      it 'returns an error' do
        subject
        expect(response.status).to eq(403)
      end
    end
  end
end
