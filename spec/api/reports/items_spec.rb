require 'app_helper'

describe Reports::Items::API do
  let(:user) { create(:user) }
  let(:category) { create(:reports_category_with_statuses) }
  let(:valid_params) do
    {
      latitude: FFaker::Geolocation.lat,
      longitude: FFaker::Geolocation.lng,
      address: 'Fake Street, 1234',
      reference: 'Close to the store',
      description: 'The situation is really bad around here.',
      images: [
        Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read),
        Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
      ]
    }
  end

  context 'POST /reports/:category_id/items' do
    it 'should create a new report with lat/long and address' do
      post '/reports/' + category.id.to_s + '/items', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body['report']

      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(valid_params[:address])
      expect(body['protocol']).to_not be_blank
      expect(body['reference']).to eq(valid_params[:reference])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(valid_params[:latitude])
      expect(body['position']['longitude']).to eq(valid_params[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil

      expect(body['images'][0]['high']).to_not be_empty
      expect(body['images'][0]['low']).to_not be_empty
      expect(body['images'][1]['high']).to_not be_empty
      expect(body['images'][1]['low']).to_not be_empty
    end

    it 'should create a new report without latitude and longitude' do
      valid_params.delete(:latitude)
      valid_params.delete(:longitude)
      allow(GeocodeReportsItem).to receive(:perform_in)

      post '/reports/' + category.id.to_s + '/items', valid_params, auth(user)
      expect(response.status).to eq(201)

      report = Reports::Item.last
      expect(report.position).to be_nil
      expect(GeocodeReportsItem).to have_received(:perform_in).with(30.seconds, report.id)
    end

    it 'should create a new report when an inventory item is given' do
      inventory_item = create(:inventory_item)
      valid_params_for_report_with_inventory_item = {
          inventory_item_id: inventory_item.id
      }.merge(valid_params.except(:latitude, :longitude, :address))

      post '/reports/' + category.id.to_s + '/items', valid_params_for_report_with_inventory_item, auth(user)
      body = parsed_body['report']
      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(inventory_item.location[:address])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(inventory_item.location[:latitude])
      expect(body['position']['longitude']).to eq(inventory_item.location[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil

      # TODO: Fix these validations
      # expect(body['images'][0]['url']).to eq('/uploads/' + valid_params[:images][0].original_filename)
      # expect(body['images'][1]['url']).to eq('/uploads/' + valid_params[:images][1].original_filename)
    end

    it 'create a new report with uploaded images instead of encoded ones' do
      valid_params[:images] = [
        fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg"),
        fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg")
      ]

      post '/reports/' + category.id.to_s + '/items', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body['report']

      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(valid_params[:address])
      expect(body['reference']).to eq(valid_params[:reference])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(valid_params[:latitude])
      expect(body['position']['longitude']).to eq(valid_params[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil
      expect(body['category']).to_not be_nil
      expect(body['images'][0]['high']).to_not be_empty
      expect(body['images'][0]['low']).to_not be_empty
      expect(body['images'][1]['high']).to_not be_empty
      expect(body['images'][1]['low']).to_not be_empty
    end

    it 'accepts passing an user_id as argument' do
      other_user = create(:user)
      valid_params[:user_id] = other_user.id

      post "/reports/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      expect(category.reports.last.user).to eq(other_user)
      expect(category.reports.last.reporter).to eq(user)
    end

    it 'creates a confidential report' do
      valid_params[:confidential] = true

      post "/reports/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      expect(category.reports.last.confidential).to be_truthy
    end

    context 'from panel' do
      subject do
        post "/reports/#{category.id}/items", valid_params, auth(user)
      end

      context 'user has permission to create from panel' do
        it 'allows creation of the report' do
          valid_params[:from_panel] = true
          subject

          expect(response.status).to eq(201)
        end
      end

      context "user doesn't have permission to create from panel" do
        before do
          GroupPermission.where(group_id: user.groups.pluck(:id)).update_all(create_reports_from_panel: false, reports_full_access: false)
        end

        it 'disallows creation of the report' do
          valid_params[:from_panel] = true
          subject

          expect(response.status).to_not eq(201)
        end
      end
    end

    context 'user with permission to edit reports category' do
      let(:group) { create(:group) }

      subject do
        post "/reports/#{category.id}/items", valid_params, auth(user)
      end

      before do
        group.permission.update(reports_categories_edit: [category.id])
        user.update!(groups: [group])
      end

      it 'allows creation of the report' do
        subject

        expect(response.status).to eq(201)
      end
    end

    context 'forwarding to default group solver' do
      context 'category has a default group solver' do
        let(:group) { create(:group) }

        let(:setting) do
          category.settings.find_by(namespace_id: user.namespace_id)
        end

        before do
          setting.solver_groups = [group]
          setting.default_solver_group = group
          setting.save!
        end

        it 'gets forwarded to the group' do
          post "/reports/#{category.id}/items", valid_params, auth(user)

          expect(response.status).to eq(201)

          report = category.reports.last
          expect(report.assigned_group).to eq(group)
        end
      end
    end

    context 'forwarding to category perimeter group solver' do
      let(:category) { create(:reports_category_with_statuses) }
      let!(:perimeter) { create(:reports_perimeter, :imported) }

      let!(:category_perimeter) do
        create(:reports_category_perimeter,
          category: category,
          perimeter: perimeter,
          namespace: user.namespace
        )
      end

      let(:setting) { category.settings.find_by(namespace_id: user.namespace_id) }

      let(:valid_params) do
        {
          latitude: -22.906662240700097,
          longitude: -43.181757530761786,
          address: 'Praça Tiradentes',
          city: 'Rio de Janeiro',
          county: 'Brasil',
          district: 'Centro',
          number: '10',
          postal_code: '20060-070',
          state: 'RJ'
        }
      end

      before do
        setting.perimeters = true
        setting.save!
      end

      it 'assigns group and perimeter' do
        post "/reports/#{category.id}/items", valid_params, auth(user)

        expect(response.status).to eq(201)

        body = parsed_body['report']
        report = Reports::Item.find(body['id'])

        expect(report.perimeter).to eq(perimeter)
        expect(report.assigned_group).to eq(category_perimeter.group)
      end
    end

    context 'submitting custom fields' do
      let(:custom_fields) { create_list(:reports_custom_field, 3) }
      let(:custom_fields_params) do
        hash = {}

        custom_fields.each do |custom_field|
          hash[custom_field.id.to_s] = 'Test text'
        end

        hash
      end

      before do
        category.update!(custom_fields: custom_fields)
      end

      it 'saves the custom fields correctly' do
        valid_params['custom_fields'] = custom_fields_params

        post "/reports/#{category.id}/items", valid_params, auth(user)
        expect(response.status).to eq(201)

        expect(parsed_body['report']['custom_fields']).to match(custom_fields_params)
      end
    end
  end

  context 'PUT /reports/:category_id/items/:id' do
    let(:existent_item) { create(:reports_item_with_images, category: category) }

    it 'updates an existent report' do
      put "/reports/#{category.id}/items/#{existent_item.id}",
          valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['report']

      expect(body['id']).to_not be_nil
      expect(body['address']).to eq(valid_params[:address])
      expect(body['reference']).to eq(valid_params[:reference])
      expect(body['description']).to eq(valid_params[:description])
      expect(body['position']['latitude']).to eq(valid_params[:latitude])
      expect(body['position']['longitude']).to eq(valid_params[:longitude])
      expect(body['status']['id']).to_not be_nil
      expect(body['status']['title']).to_not be_nil
      expect(body['status']['color']).to_not be_nil
      expect(body['status']['final']).to_not be_nil
      expect(body['status']['initial']).to_not be_nil
    end

    it 'is able to change the images' do
      valid_params = {
        images: [{
          id: existent_item.images.first.id,
          title: 'Image',
          file: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_marker.png").read)
        }]
      }

      old_image_url = existent_item.images.first.url
      old_image_url2 = existent_item.images.last.url

      put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['report']

      expect(existent_item.reload.images.first.url).to_not eq(old_image_url)
      expect(existent_item.reload.images.first.title).to eq('Image')
      expect(existent_item.reload.images.last.url).to eq(old_image_url2)
    end

    context 'updating the status' do
      it 'is able to update the status passing status_id' do
        status = category.status_categories.final.first.status
        valid_params['status_id'] = status.id

        expect(existent_item.id).to_not eq(status.id)
        put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body['report']
        expect(body['status']['id']).to eq(status.id)
      end

      context 'when the status is private' do
        let(:status) { create(:status) }

        let!(:status_category) do
          create(:reports_status_category, category: category, status: status,
                 private: true)
        end

        before do
          group = create(:group)
          group.permission.update(
            reports_full_access: false,
            reports_items_edit: [category.id]
          )
          user.groups = [group]
          user.save!

          allow(UserMailer).to receive(:notify_report_status_update).and_return(
                                 double('mail', deliver: true)
                               )
        end

        it "doesn't notify the user" do
          valid_params['status_id'] = status_category.reports_status_id

          expect(existent_item.reports_status_id).to_not eq(status.id)
          put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)

          expect(response.status).to eq(200)

          body = parsed_body['report']
          expect(body['status']['id']).to eq(status.id)
          expect(UserMailer).to_not have_received(:notify_report_status_update)
        end
      end
    end

    it 'is able to update the report category' do
      new_category = create(:reports_category_with_statuses)

      valid_params = {
        'category_id' => new_category.id
      }

      put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)
      expect(parsed_body['report']['category']['id']).to eq(new_category.id)
    end

    it 'changes the param to confidential' do
      valid_params['confidential'] = true
      put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['report']
      expect(body['confidential']).to be_truthy
    end

    context 'validating versions' do
      context 'valid version' do
        it 'updates the item' do
          valid_params['version'] = existent_item.version

          put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)
          expect(response.status).to eq(200)
        end
      end

      context 'invalid version' do
        it "doesn't update the item" do
          valid_params['version'] = 2

          put "/reports/#{category.id}/items/#{existent_item.id}", valid_params, auth(user)
          expect(response.status).to eq(400)
          expect(parsed_body['type']).to eq('version_mismatch')
        end
      end
    end

    context 'update latitude and longitude' do
      let(:category) { create(:reports_category_with_statuses, perimeters: true) }
      let(:item) { create(:reports_item_with_images, category: category, perimeter: create(:reports_perimeter)) }
      let(:perimeter) { create(:reports_perimeter, :imported, namespace: user.namespace) }

      let!(:category_perimeter) do
        create(:reports_category_perimeter,
          category: category,
          perimeter: perimeter,
          namespace: user.namespace
        )
      end

      let(:setting) { category.settings.find_by(namespace_id: user.namespace_id) }

      let(:valid_params) do
        {
          latitude: -22.906662240700097,
          longitude: -43.181757530761786,
          address: 'Praça Tiradentes'
        }
      end

      before do
        setting.perimeters = true
        setting.save!
      end

      it 'gets forwarded to category perimeter group' do
        put "/reports/#{item.category.id}/items/#{item.id}", valid_params, auth(user)

        item.reload

        expect(item.perimeter).to eq(perimeter)
        expect(item.assigned_group).to eq(category_perimeter.group)
      end
    end
  end

  context 'PUT /reports/:category_id/items/:id/change_category' do
    let(:item) { create(:reports_item_with_images, category: category) }
    let(:other_category) { create(:reports_category_with_statuses) }
    let(:other_status) do
      other_category.statuses.first
    end

    context 'valid category and status' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "new_category_id": #{other_category.id},
            "new_status_id": #{other_status.id}
          }
        JSON
      end

      it 'updates the category and status of the item correctly' do
        put "/reports/#{item.category.id}/items/#{item.id}/change_category", valid_params, auth(user)
        item.reload

        expect(item.category).to eq(other_category)
        expect(item.status).to eq(other_status)
      end
    end
  end

  context 'PUT /reports/:category_id/items/:id/forward' do
    let(:item) { create(:reports_item_with_images, category: category) }
    let(:group) { create(:group) }

    before do
      category.solver_groups = [group]
      category.save!
    end

    context 'valid group for forwarding' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "group_id": #{group.id}
          }
        JSON
      end

      context 'user does have permission to forward' do
        let(:user_group) { create(:group) }
        let(:setting)    { item.setting }

        before do
          user_group.permission.update(reports_items_forward: [item.category.id])
          user.groups = [user_group]
          user.save!

          setting.solver_groups = [group]
          setting.save!
        end

        it 'forwards item to group correctly' do
          put "/reports/#{item.category.id}/items/#{item.id}/forward", valid_params, auth(user)
          item.reload

          expect(item.assigned_group).to eq(group)
          expect(item.assigned_user).to be_nil
        end
      end

      context 'user doest\'t have permission to forward' do
        let(:user_group) { create(:group) }

        before do
          user.groups = [user_group]
          user.save!
        end

        it 'throw a permission error' do
          put "/reports/#{item.category.id}/items/#{item.id}/forward", valid_params, auth(user)
          expect(response.status).to eq(403)
        end
      end
    end
  end

  context 'PUT /reports/:category_id/items/:id/assign' do
    let(:item) { create(:reports_item_with_images, category: category) }
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    before do
      category.solver_groups = [group]
      category.save!

      item.update!(assigned_group: group)

      user.groups << group
      user.save!
    end

    context 'valid category and status' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "user_id": #{user.id}
          }
        JSON
      end

      it 'updates the category and status of the item correctly' do
        put "/reports/#{item.category.id}/items/#{item.id}/assign", valid_params, auth(user)
        item.reload

        expect(item.assigned_user).to eq(user)
      end
    end
  end

  context 'PUT /reports/:category_id/items/:id/update_status' do
    let(:item) { create(:reports_item_with_images, category: category) }
    let(:status) { create(:status) }

    before do
      create(:reports_status_category, status: status, category: category)
    end

    context 'valid status for updating' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "status_id": #{status.id}
          }
        JSON
      end

      context 'user does have permission to alter the status' do
        let(:user_group) { create(:group) }

        before do
          user_group.permission.update(reports_items_alter_status: [item.category.id])
          user.groups = [user_group]
          user.save!
        end

        it 'updates the item status correctly' do
          put "/reports/#{item.category.id}/items/#{item.id}/update_status", valid_params, auth(user)
          item.reload

          expect(item.status).to eq(status)
        end

        context 'category requires comment when updating the status' do
          before do
            category.update!(comment_required_when_updating_status: true)
          end

          context 'user does provide a comment' do
            let(:message) { 'This is a test' }
            let(:visibility) { Reports::Comment::PRIVATE }

            before do
              valid_params[:comment] = message
              valid_params[:comment_visibility] = visibility
            end

            it 'updates the status and creates the comment' do
              put "/reports/#{item.category.id}/items/#{item.id}/update_status", valid_params, auth(user)
              expect(response.status).to eq(200)
              item.reload

              expect(item.status).to eq(status)

              comment = item.comments.last
              expect(comment.message).to eq(message)
              expect(comment.author).to eq(user)
              expect(comment.visibility).to eq(visibility)
            end
          end

          context "user doesn't provide a comment" do
            it 'updates the status and creates the comment' do
              put "/reports/#{item.category.id}/items/#{item.id}/update_status", valid_params, auth(user)
              expect(response.status).to eq(400)
            end
          end
        end
      end

      context 'user doest\'t have permission to forward' do
        let(:user_group) { create(:group) }

        before do
          user.groups = [user_group]
          user.save!
        end

        it 'throw a permission error' do
          put "/reports/#{item.category.id}/items/#{item.id}/update_status", valid_params, auth(user)
          expect(response.status).to eq(403)
        end
      end
    end
  end

  context 'GET /reports/items' do
    context 'no filters' do
      let!(:reports) do
        create_list(:reports_item_with_images, 20, category: category)
      end

      it 'return all reports ordenated and paginated' do
        get '/reports/items?page=2&per_page=15&sort=id&order=asc&return_fields=id',
            nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('reports')
        expect(body['reports'].size).to eq(5)

        expect(
          body['reports'].map { |r| r['id'] }
        ).to match_array(reports[15..19].map(&:id))
      end

      it 'returns inventory_categories and comments on listing' do
        get '/reports/items', { display_type: 'full' }, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].first['inventory_categories']).to_not be_nil
        expect(body['reports'].first['comments']).to_not be_nil
      end
    end

    context 'user filter' do
      let!(:reports) do
        create_list(
          :reports_item_with_images, 12,
          user: user, category: category
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 5,
          category: category
        )
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "user_id": #{user.id}
          }
        JSON
      end

      it 'returns all reports for user' do
        get '/reports/items?return_fields=id', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('reports')
        expect(body['reports'].size).to eq(12)
        body['reports'].each do |r|
          expect(Reports::Item.find(r['id']).user_id).to eq(user.id)
        end
      end
    end

    context 'category filter' do
      let!(:reports) do
        create_list(
          :reports_item_with_images, 16,
          category: category
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 5
        )
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "category_id": #{category.id}
          }
        JSON
      end

      it 'returns all reports for category' do
        get '/reports/items?return_fields=category_id', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('reports')
        expect(body['reports'].size).to eq(16)
        body['reports'].each do |r|
          expect(r['category_id']).to eq(category.id)
        end
      end
    end

    context 'date filter' do
      let!(:reports) do
        reports = create_list(
          :reports_item_with_images, 3
        )

        reports.each do |report|
          report.update(created_at: DateTime.new(2014, 1, 10))
        end
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 2
        )
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "begin_date": "#{Date.new(2014, 1, 9).iso8601}",
            "end_date": "#{Date.new(2014, 1, 13).iso8601}"
          }
        JSON
      end

      it 'returns all reports in the date range' do
        get '/reports/items?return_fields=id', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(reports.length)
        response_ids = body['reports'].map { |r| r['id'] }
        wrong_reports.each do |wrong_report|
          expect(wrong_report.id.in?(response_ids)).to eq(false)
        end
      end

      it 'returns all reports even with one param' do
        valid_params.delete('begin_date')

        get '/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(3)
        expect(body['reports'].map { |r| r['id'] }).to match_array(reports.map(&:id))
      end

      context 'return the right report even in a different timezone' do
        let(:valid_params) do
          Oj.load <<-JSON
            {
              "begin_date": "2015-01-25T00:00:00-08:00",
              "end_date": "2015-01-25T23:59:59-08:00"
            }
          JSON
        end

        before do
          reports.each do |report|
            report.update(
              created_at: DateTime.new(2015, 1, 26).beginning_of_day.in_time_zone('Brasilia')
            )
          end
        end

        it 'returns all reports in the date range' do
          get '/reports/items?return_fields=id', valid_params, auth(user)
          expect(response.status).to eq(200)
          body = parsed_body

          expect(body['reports'].size).to eq(reports.length)
          response_ids = body['reports'].map { |r| r['id'] }
          wrong_reports.each do |wrong_report|
            expect(wrong_report.id.in?(response_ids)).to eq(false)
          end
        end
      end
    end

    context 'statuses filter' do
      let!(:status) { category.statuses.where(initial: false).first }
      let!(:reports) do
        create_list(
          :reports_item, 7,
          category: category,
          status: status
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item, 5,
          category: category
        )
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "statuses": [#{status.id}]
          }
        JSON
      end

      it 'returns all reports with correct statuses' do
        get '/reports/items?return_fields=id', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(reports.length)
        expect(body['reports'].map { |r| r['id'] }).to match_array(reports.map { |r| r.id })
      end

      it 'accepts only one id as argument' do
        valid_params['statuses'] = status.id

        get '/reports/items?return_fields=id', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(reports.length)
        expected_ids = Set.new(reports.map { |r| r.id })
        expect(Set.new(body['reports'].map { |r| r['id'] })).to eq(expected_ids)
      end
    end

    context 'multiple filters' do
      let!(:reports) do
        create_list(
          :reports_item_with_images, 11,
          category: category, user: user
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 5,
          category: category
        )
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "category_id": #{category.id},
            "user_id": #{user.id}
          }
        JSON
      end

      it 'returns all reports for category' do
        get '/reports/items?return_fields=id', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('reports')
        expect(body['reports'].size).to eq(11)
        body['reports'].each do |r|
          expect(Reports::Item.find(r['id']).user_id).to eq(user.id)
        end
      end
    end

    context 'guest group' do
      let(:other_category) { create(:reports_category_with_statuses) }
      let!(:reports) do
        create_list(
          :reports_item_with_images, 2,
          category: category, user: user
        )
      end
      let!(:wrong_reports) do
        create_list(
          :reports_item_with_images, 3,
          category: other_category
        )
      end

      before do
        Group.guest.each do |group|
          group.permission.reports_items_read_public = [category.id]
          group.save!
        end
      end

      it 'only can see the category it has the permission' do
        get '/reports/items?return_fields=id', nil, auth(nil, user.namespace_id)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].size).to eq(2)
        expect(body['reports'].map do |i|
          i['id']
        end).to match_array(reports.map(&:id))
      end
    end
  end

  context 'GET /reports/items/:id' do
    let(:user) { create(:user) }
    let(:item) { create(:reports_item_with_images, :with_feedback) }

    it 'returns the report data' do
      get "/reports/items/#{item.id}", nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      report = parsed_body['report']

      expect(report['id']).to_not be_nil
      expect(report['address']).to_not be_nil
      expect(report['description']).to_not be_nil
      expect(report['position']['latitude']).to_not be_nil
      expect(report['position']['latitude']).to_not be_nil
      expect(report['category_icon']).to_not be_nil
      expect(report['status']['id']).to_not be_nil
      expect(report['status']['title']).to_not be_nil
      expect(report['status']['color']).to_not be_nil
      expect(report['status']['final']).to_not be_nil
      expect(report['status']['initial']).to_not be_nil
      expect(report['category']).to_not be_nil
      expect(report['feedback']).to be_present
    end

    context 'if the user that created is the same' do
      let(:item) { create(:reports_item_with_images, :with_feedback, user: user) }

      it 'shows the protocol' do
        get "/reports/items/#{item.id}?return_fields=id,protocol", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['protocol']).to_not be_blank
      end

      it 'shows the user' do
        get "/reports/items/#{item.id}?return_fields=id,user", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['user']).to_not be_blank
      end
    end

    context "if the user didn't create the item" do
      let(:item) { create(:reports_item_with_images) }

      before do
        user.groups = Group.guest
        user.save!
      end

      it "doesn't show the protocol" do
        get "/reports/items/#{item.id}?return_fields=id,protocol", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['protocol']).to be_blank
      end

      it 'shows anonymous user' do
        get "/reports/items/#{item.id}?return_fields=id,user", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['user']['name']).to eq('Anônimo')
      end
    end

    context 'if the user can see private report data' do
      let(:item) { create(:reports_item_with_images) }

      before do
        user.groups.first.permission.update(reports_items_read_private: [item.category.id])
        user.save!
      end

      it 'does show the protocol' do
        get "/reports/items/#{item.id}?return_fields=id,protocol", nil, auth(user)
        expect(response.status).to eq(200)
        report = parsed_body['report']

        expect(report['protocol']).to_not be_blank
      end
    end
  end

  context 'DELETE /reports/items/:id' do
    let!(:item) { create(:reports_item_with_images) }

    it 'removes a report item' do
      delete "/reports/items/#{item.id}", {}, auth(user)
      expect(response.status).to eq(204)

      expect { item.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'GET /reports/:category_id/items' do
    let!(:items) { create_list(:reports_item_with_images, 3, category: category) }

    before do
      Group.guest.first.permission.update(reports_full_access: true)
    end

    it 'should retrieve a list of reports from a given category' do
      get '/reports/' + category.id.to_s + '/items', nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      body = parsed_body['reports']

      expect(body.count).to eq(3)

      body.each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['status_id']).to_not be_nil
      end
    end

    context 'search by position' do
      let(:empty_category) { create(:reports_category_with_statuses) }
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "category_id": #{empty_category.id},
            "position": {
              "latitude": "-23.5989650",
              "longitude": "-46.6836310",
              "distance": 1000
            }
          }
        JSON
      end

      it 'returns closer report positions when passed position arg' do
        # Creating items
        points_nearby = [
          [-23.5989650, -46.6836310],
          [-23.5989340, -46.6835700],
          [-23.5981840, -46.6842480],
          [-23.5986170, -46.6828580]
        ]

        points_distant = [
          [-40.34, -12.3045],
          [-40.34, -12.3045],
          [-40.34, -12.3045],
          [-40.34, -12.3045]
        ]

        nearby_items = points_nearby.map do |latlng|
          create(
            :reports_item_with_images,
            position: RGeo::Geographic.simple_mercator_factory.point(latlng[1], latlng[0]),
            category: empty_category
          )
        end

        distant_items = points_distant.map do |latlng|
          create(
            :reports_item_with_images,
            position: RGeo::Geographic.simple_mercator_factory.point(latlng[1], latlng[0]),
            category: empty_category
          )
        end

        expect(empty_category.reports.count).to eq(8)
        expect(empty_category.reports.map(&:position)).to_not include(nil)

        get '/reports/items?return_fields=id', valid_params, auth(nil, user.namespace_id)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['reports'].map { |i| i['id'] }).to match_array(nearby_items.map { |i| i['id'] })
      end
    end
  end

  context 'GET /reports/inventory/:invetory_item_id/items' do
    let(:inventory_item) { create(:inventory_item) }
    let!(:items) do
      create_list(:reports_item_with_images, 3,
                     category: category, inventory_item: inventory_item)
    end

    before do
      Group.guest.first.permission.update(reports_full_access: true)
    end

    it 'should retrieve a list of reports from a given category' do
      get '/reports/inventory/' + inventory_item.id.to_s + '/items', nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      body = parsed_body['reports']
      expect(body.count).to eq(3)

      body.each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['longitude']).to_not be_nil
        expect(report['status_id']).to_not be_nil
      end
    end
  end

  context 'GET /reports/users/:user_id/items' do
    let!(:items) do
      create_list(:reports_item_with_images, 3,
                     category: category, user: user)
    end

    before do
      Group.guest.first.permission.update(reports_full_access: true)
    end

    it 'should retrieve a list of reports from a given user' do
      get '/reports/users/' + user.id.to_s + '/items', nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body['reports'].count).to eq(3)

      body['reports'].each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['longitude']).to_not be_nil
        expect(report['status']['id']).to_not be_nil
        expect(report['category']['id']).to_not be_nil
      end

      expect(body['total_reports_by_user']).to eq(3)
    end
  end

  context 'GET /reports/users/me/items' do
    let!(:items) do
      create_list(:reports_item_with_images, 3,
                     category: category, user: user)
    end

    it 'should retrieve a list of reports from the current user' do
      get '/reports/users/me/items', nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body['reports'].count).to eq(3)

      body['reports'].each do |report|
        expect(report['id']).to_not be_nil
        expect(report['address']).to_not be_nil
        expect(report['description']).to_not be_nil
        expect(report['position']['latitude']).to_not be_nil
        expect(report['position']['longitude']).to_not be_nil
        expect(report['status']['id']).to_not be_nil
        expect(report['status']['title']).to_not be_nil
        expect(report['status']['color']).to_not be_nil
        expect(report['status']['final']).to_not be_nil
        expect(report['status']['initial']).to_not be_nil
        expect(report['category']).to_not be_nil
      end

      expect(body['total_reports_by_user']).to eq(3)
    end
  end
end
