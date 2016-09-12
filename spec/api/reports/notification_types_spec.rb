require 'spec_helper'

describe Reports::NotificationTypes::API do
  let!(:namespace) { Namespace.first_or_create(default: true, name: 'Namespace') }
  let(:user)       { create(:user) }
  let(:category)   { create(:reports_category_with_statuses) }
  let(:setting)    { category.settings.find_by(namespace_id: namespace.id) }

  describe 'GET /reports/categories/:category_id/notification_types' do
    let!(:notification_types) do
      create_list(:reports_notification_type, 2, category: category)
    end

    before do
      get "/reports/categories/#{category.id}/notification_types", nil, auth(user)
    end

    it "returns all the category's notification types" do
      notification_types.each do |notification_type|
        expect(parsed_body['notification_types']).to include_an_entity_of(notification_type.reload)
      end
    end
  end

  describe 'POST /reports/categories/:category_id/notification_types' do
    let(:status) { create(:status, :with_category, category: category) }

    let(:valid_params) do
      {
        title: 'Notificação de teste',
        reports_status_id: status.id,
        default_deadline_in_days: 45,
        layout: '',
        order: 0,
      }
    end

    subject do
      post "/reports/categories/#{category.id}/notification_types", valid_params, auth(user)
    end

    it 'creates the notification type' do
      subject
      expect(response.status).to be_a_requisition_created
      notification_type = Reports::NotificationType.for_category(category, user.namespace_id).last

      expect(notification_type.title).to eq(valid_params[:title])
      expect(notification_type.reports_status_id).to eq(valid_params[:reports_status_id])
      expect(notification_type.default_deadline_in_days).to eq(valid_params[:default_deadline_in_days])
      expect(notification_type.layout).to eq(valid_params[:layout])
      expect(notification_type.order).to eq(valid_params[:order])
    end

    it 'creates the notification type without `default_deadline_in_days`' do
      valid_params[:default_deadline_in_days] = nil

      subject

      expect(response.status).to be_a_requisition_created

      notification_type = Reports::NotificationType.for_category(category, user.namespace_id).last

      expect(notification_type.default_deadline_in_days).to be_nil
    end

    context "with status that doesn't belong to the category" do
      let(:status) { create(:status) }

      it 'is a bad request' do
        subject
        expect(response.status).to be_a_bad_request
        expect(parsed_body['type']).to eq('model_validation')
      end
    end

    context 'status have `ordered_notifications` enabled' do
      before do
        setting.update!(ordered_notifications: true)
      end

      context 'params without `order`' do
        before do
          valid_params.delete(:order)
        end

        it 'is a bad request' do
          subject
          expect(response.status).to be_a_bad_request
          expect(parsed_body['type']).to eq('model_validation')
        end
      end

      context 'params with `order`' do
        it 'is a success request' do
          subject
          expect(response.status).to be_a_requisition_created
        end
      end
    end
  end

  describe 'PUT /reports/categories/:category_id/notification_types/:id' do
    let(:notification_type) { create(:reports_notification_type, category: category) }
    let(:status) { create(:status, :with_category, category: category) }

    let(:valid_params) do
      {
        title: 'Notificação de teste',
        reports_status_id: status.id,
        default_deadline_in_days: 45,
        layout: '',
        order: 0,
      }
    end

    before do
      put "/reports/categories/#{category.id}/notification_types/#{notification_type.id}", valid_params, auth(user)
    end

    it 'updates the notification type' do
      expect(response.status).to be_a_success_request
      notification_type.reload

      expect(notification_type.title).to eq(valid_params[:title])
      expect(notification_type.reports_status_id).to eq(valid_params[:reports_status_id])
      expect(notification_type.default_deadline_in_days).to eq(valid_params[:default_deadline_in_days])
      expect(notification_type.layout).to eq(valid_params[:layout])
      expect(notification_type.order).to eq(valid_params[:order])
    end

    context "with status that doesn't belong to the category" do
      let(:status) { create(:status) }

      it 'is a bad request' do
        expect(response.status).to be_a_bad_request
        expect(parsed_body['type']).to eq('model_validation')
      end
    end
  end

  describe 'DELETE /reports/categories/:category_id/notification_types/:id' do
    let(:notification_type) { create(:reports_notification_type, category: category) }

    subject do
      delete "/reports/categories/#{category.id}/notification_types/#{notification_type.id}", nil, auth(user)
    end

    it 'deactivates the notification type' do
      subject
      expect(notification_type.reload).to be_deactivated
    end
  end
end
