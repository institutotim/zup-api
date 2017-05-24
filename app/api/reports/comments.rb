module Reports::Comments
  class API < Base::API
    namespace ':id/comments' do
      desc 'Get all comments from a report item'
      params do
        requires :id, type: Integer, desc: 'The id of the report'
      end
      get do
        report = Reports::Item.find(params[:id])

        comments = Reports::GetCommentsForUser.new(report, current_user).comments

        {
          comments: Reports::Comment::Entity.represent(comments)
        }
      end

      desc 'Create a comment for the report item'
      params do
        requires :id, type: Integer,
                 desc: 'The id of the report'
        requires :visibility, type: Integer,
                 desc: '0 = Public, 1 = Private, 2 = Internal'
        optional :message, type: String,
                 desc: 'The message itself'
        optional :replicate, type: Boolean, default: false,
                 desc: 'Replicate the change to grouped reports'
      end
      post do
        authenticate!

        report = Reports::Item.find(params[:id])

        comment_params = safe_params.permit(:visibility, :message)
        comment_params[:author_id] = current_user.id
        comment_params[:reports_item_id] = report.id

        service = Reports::CreateComment.new(current_user, report)
        service.build(comment_params)

        if service.comment.internal?
          validate_permission!(:create_internal, service.comment)
        elsif service.comment.private?
          validate_permission!(:create, service.comment)
        end

        service.save!

        if params[:replicate]
          CopyToReportsItems.perform_async(current_user.id, report.id, 'comment',
            comment_id: service.comment.id)
        end

        {
          comment: Reports::Comment::Entity.represent(service.comment)
        }
      end
    end
  end
end
