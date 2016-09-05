module Reports::Feedbacks
  class API < Base::API
    namespace ':id/feedback' do
      desc 'Get the feedback for the report item'
      params do
        requires :id, type: Integer, desc: 'The id of the report'
      end
      get do
        authenticate!

        report = Reports::Item.find(params[:id])

        {
          feedback: \
            Reports::Feedback::Entity.represent(report.feedback)
        }
      end

      desc 'Create a feedback for the report item'
      params do
        requires :id, type: Integer,
                 desc: 'The id of the report'
        requires :kind, type: String,
                 desc: "The kind of the feedback, can be 'positive' or 'negative'"
        optional :content, type: String,
                 desc: 'The content of the report item'
        optional :images, type: Array,
               desc: 'An array of images(post data or encoded on base64) for this feedback'
      end
      post do
        authenticate!

        report = Reports::Item.find(params[:id])

        if report.setting.user_response_time.present?
          unless report.can_receive_feedback?
            error!('A solicitação ainda não foi resolvida ou o prazo já expirou', 401)
          end
        else
          error!('A solicitação não aceita feedback após a resolução', 401)
        end

        feedback_params = safe_params.permit(:kind, :content)

        feedback_params[:user_id] = current_user.id
        feedback_params.merge!(reports_item_id: safe_params[:id])

        feedback = report.create_feedback!(feedback_params)

        if params[:images]
          feedback.update_images!(params[:images])
        end

        {
          feedback: Reports::Feedback::Entity.represent(feedback)
        }
      end
    end
  end
end
