module Reports
  class UpdateItemFromWebhook < CreateItemFromWebhook
    attr_reader :report, :params

    def initialize(report, params)
      @report = report
      @params = params
    end

    def update!
      ActiveRecord::Base.transaction do
        report.update!(build_reports_params)
        report.reload

        if params[:external_category_id]
          category = find_category(params[:external_category_id])
        end

        if params[:status]
          status = find_or_create_status!(params[:status], category || report.category, report.namespace)
        elsif category
          status = find_or_create_status!({ name: report.status.title }, category, report.namespace)
        end

        if status && category
          Reports::ChangeItemCategory.new(report, category, status).process!
        elsif status
          Reports::UpdateItemStatus.new(report).update_status!(status)
        end

        report
      end
    end

    private

    def build_reports_params
      reports_params = {}

      # Comments params
      comments = params[:comments]

      # Report params
      reports_params = reports_params.merge_if_not_nil(
        external_category_id: params[:external_category_id],
        is_solicitation: params[:is_solicitation],
        is_report: params[:is_report],
        description: params[:description],
        address: params[:address],
        reference: params[:reference]
      )

      if params[:user]
        reports_params = reports_params.merge(
          user: create_user(params[:user], report.namespace)
        )
      end

      if params[:longitude] && params[:latitude]
        reports_params = reports_params.merge(
          position: Reports::Item.rgeo_factory.point(params[:longitude], params[:latitude])
        )
      end

      if comments
        comments.each do |comment|
          existing_comment = report.comments.find_by(message: comment[:message])

          unless existing_comment
            reports_params = reports_params.deep_merge(
              comments_attributes: [{
                author: create_user(comment[:user], report.namespace),
                message: comment[:message]
              }]
            )
          end
        end
      end

      reports_params
    end
  end
end
