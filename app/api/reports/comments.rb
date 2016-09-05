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
          comments: \
            Reports::Comment::Entity.represent(comments)
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
      end
      post do
        authenticate!

        report = Reports::Item.find(params[:id])

        comment_params = safe_params.permit(:visibility, :message)
        comment_params[:author_id] = current_user.id
        comment_params[:reports_item_id] = report.id

        comment = Reports::Comment.new(comment_params)

        validate_permission!(:create_internal, comment) if Reports::Comment::INTERNAL == comment.visibility
        validate_permission!(:create, comment) if Reports::Comment::PRIVATE == comment.visibility

        comment.save!

        Reports::NotifyUser.new(report).notify_new_comment!(comment)

        create_history = Reports::CreateHistoryEntry.new(report, current_user)
        create_history.create('comment',
                              "Inseriu um comentário #{translated_visibility(comment.visibility)}",
                              new: comment.entity(only: [:id, :message, :visibility]))

        if Reports::Comment::INTERNAL != comment.visibility && Webhook.enabled?
          SendReportThroughWebhook.perform_async(report.uuid, 'update')
        end

        {
          comment: Reports::Comment::Entity.represent(comment)
        }
      end
    end

    helpers do
      def translated_visibility(visibility)
        {
          Reports::Comment::INTERNAL => 'interno',
          Reports::Comment::PUBLIC   => 'público',
          Reports::Comment::PRIVATE  => 'privado'
        }[visibility]
      end
    end
  end
end
