require 'spec_helper'

describe Search::Reports::Notifications::API do
  let(:user) { create(:user) }

  describe 'GET /search/reports/notifications' do
    let(:item) { create(:reports_item) }
    let!(:notifications) { create_list(:reports_notification, 3, item: item) }

    it 'return all notifications' do
      get '/search/reports/notifications', nil, auth(user)
      expect(response.status).to eq(200)

      expect(parsed_body['notifications'].map { |r| r['id'] }).to match_array(notifications.map(&:id))
    end

    describe 'search' do
      context 'by days for last notification deadline' do
        let!(:correct_notifications) do
          create_list(:reports_notification, 3, item: item, overdue_at: rand(2..6).days.from_now)
        end

        let!(:wrong_notifications) do
          create_list(:reports_notification, 3, item: item, overdue_at: 15.days.from_now)
        end

        let(:params) do
          {
            days_for_last_notification_deadline: {
              begin: 2,
              end: 10
            }
          }
        end

        it 'returns the correct notifications' do
          get '/search/reports/notifications', params, auth(user)
          expect(parsed_body['notifications'].map { |r| r['id'] }).to match_array(correct_notifications.map(&:id))
        end
      end

      context 'by days since last notification filter' do
        let!(:correct_notifications) do
          create_list(:reports_notification, 3, item: item, created_at: rand(2..6).days.ago)
        end

        let!(:wrong_notifications) do
          create_list(:reports_notification, 3, item: item, created_at: 20.days.ago)
        end

        let(:params) do
          {
            days_since_last_notification: {
              begin: 1,
              end: 10
            }
          }
        end

        it 'returns the correct items' do
          get '/search/reports/notifications', params, auth(user)
          expect(response.status).to eq(200)
          expect(parsed_body['notifications'].map { |r| r['id'] }).to match_array(correct_notifications.map(&:id))
        end
      end

      context 'by days for overdue notification' do
        let!(:correct_notifications) do
          create_list(:reports_notification, 3, item: item, overdue_at: rand(2..6).days.ago)
        end

        let!(:wrong_notifications) do
          create_list(:reports_notification, 3, item: item, overdue_at: 15.days.ago)
        end

        let(:params) do
          {
            days_for_overdue_notification: {
              begin: 2,
              end: 10
            }
          }
        end

        it 'returns the correct notifications' do
          get '/search/reports/notifications', params, auth(user)
          expect(parsed_body['notifications'].map { |r| r['id'] }).to match_array(correct_notifications.map(&:id))
        end
      end
    end

    describe 'sorting' do
      let!(:notifications) { create_list(:reports_notification, 3) }

      context 'default scope' do
        it 'return all notification by created at in descending order' do
          get '/search/reports/notifications', nil, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.sort_by(&:created_at).map(&:id).sort.reverse

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      context 'by notification id' do
        it 'return all notification in ascending order' do
          get '/search/reports/notifications', { sort: 'id', order: 'asc' }, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.map(&:id).sort

          expect(returned_ids).to eq(ordered_ids)
        end

        it 'return all notification in descending order' do
          get '/search/reports/notifications', { sort: 'id', order: 'desc' }, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.map(&:id).sort.reverse

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      context 'by notification created at' do
        it 'return all notification in ascending order' do
          get '/search/reports/notifications', { sort: 'created_at', order: 'asc' }, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.sort_by(&:created_at).map(&:id).sort

          expect(returned_ids).to eq(ordered_ids)
        end

        it 'return all notification in descending order' do
          get '/search/reports/notifications', { sort: 'created_at', order: 'desc' }, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.sort_by(&:created_at).map(&:id).sort.reverse

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      context 'by notification updated at' do
        it 'return all notification in ascending order' do
          get '/search/reports/notifications', { sort: 'updated_at', order: 'asc' }, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.sort_by(&:updated_at).map(&:id).sort

          expect(returned_ids).to eq(ordered_ids)
        end

        it 'return all notification in descending order' do
          get '/search/reports/notifications', { sort: 'updated_at', order: 'desc' }, auth(user)

          returned_ids = parsed_body['notifications'].map { |r| r['id'] }
          ordered_ids  = notifications.sort_by(&:updated_at).map(&:id).sort.reverse

          expect(returned_ids).to eq(ordered_ids)
        end
      end
    end
  end
end
