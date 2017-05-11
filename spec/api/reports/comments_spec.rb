require 'spec_helper'

describe Reports::Comments do
  let(:user) { create(:user) }
  let(:item) { create(:reports_item) }

  describe 'GET :id/comments' do
    subject { get "/reports/#{item.id}/comments", nil, auth(user) }

    let!(:public_comments) do
      create_list(:reports_comment, 2,
                  item: item,
                  visibility: Reports::Comment::PUBLIC)
    end
    let!(:private_comments) do
      create_list(:reports_comment, 2,
                  item: item,
                  visibility: Reports::Comment::PRIVATE)
    end
    let!(:internal_comments) do
      create_list(:reports_comment, 2,
                  item: item,
                  visibility: Reports::Comment::INTERNAL)
    end

    context 'user is not the author' do
      before do
        user.groups = Group.guest
        user.save!
      end

      it 'returns all public comments' do
        subject

        expect(response.status).to eq(200)
        comments = parsed_body['comments']
        expect(comments.map { |c| c['id'] }).to match_array(public_comments.map(&:id))
      end
    end

    context 'user is the author' do
      before do
        user.groups = Group.guest
        user.save!

        item.update!(user: user)
      end

      it 'returns all public and private comments' do
        subject

        expect(response.status).to eq(200)
        comments = parsed_body['comments']
        expect(comments.map { |c| c['id'] }).to match_array(public_comments.map(&:id) + private_comments.map(&:id))
      end
    end

    context 'user has permission to view and edit report' do
      before do
        group = create(:group)
        group.permission.update(reports_items_edit: [item.category.id])
        user.groups = [group]
        user.save!
      end

      it 'returns all public and private comments' do
        subject

        expect(response.status).to eq(200)
        comments = parsed_body['comments']
        expect(comments.map { |c| c['id'] }).to match_array(
          public_comments.map(&:id) + private_comments.map(&:id) + internal_comments.map(&:id)
        )
      end
    end
  end

  describe 'POST :id/comments' do
    subject { post "/reports/#{item.id}/comments", valid_params, auth(user) }

    context 'with valid params' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "message": "Test message",
            "visibility": 0
          }
        JSON
      end

      it 'creates the comment' do
        subject

        expect(response.status).to eq(201)

        created_comment = item.comments.last
        expect(created_comment.message).to eq('Test message')
        expect(created_comment.visibility).to eq(Reports::Comment::PUBLIC)
      end

      it 'replicate to grouped reports' do
        valid_params[:replicate] = true
        allow_any_instance_of(Reports::Comment).to receive(:id) { 10000 }

        expect(CopyToReportsItems).to receive(:perform_async).with(user.id,
          item.id, 'comment', comment_id: 10000)

        subject
        expect(response.status).to eq(201)
      end
    end

    context 'when user hasn\'t permissions to create private comments' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "message": "Test message",
            "visibility": 1
          }
        JSON
      end

      before do
        group = create(:group)
        group.permission.update(reports_items_read_private: [item.category.id])
        user.groups = [group]
        user.save!
      end

      it 'returns error' do
        subject

        expect(response.status).to eq(403)
      end
    end

    context 'when user has permissions to create private comments' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "message": "Test message",
            "visibility": 1
          }
        JSON
      end

      before do
        group = create(:group)
        group.permission.update(reports_items_create_comment: [item.category.id])
        user.groups = [group]
        user.save!
      end

      it 'creates the comment' do
        subject

        expect(response.status).to eq(201)
      end
    end
  end
end
