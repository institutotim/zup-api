module Reports
  class SerializeToWebhook
    attr_reader :report, :params

    def initialize(report)
      @report = report
      @params = {}
    end

    def serialize(options = {})
      adds_report_data
      adds_images_data unless options[:skip_images]
      adds_comments_data
      adds_status_data

      params
    end

    private

    def adds_report_data
      @params = params.merge(
        latitude: report.position.y,
        longitude: report.position.x,
        is_report: report?,
        is_solicitation: solicitation?,
        description: report.description,
        address: report.address,
        number: report.number,
        district: report.district,
        postal_code: report.postal_code,
        city: report.city,
        state: report.state,
        country: report.country,
        reference: report.reference,
        user: build_user_data(report.user),
        uuid: report.uuid,
        external_category_id: external_category_id,
        protocol: report.protocol,
        created_at: report.created_at
      )
    end

    def adds_images_data
      @params = params.merge(
        images: serialize_images(report.images)
      )
    end

    def adds_comments_data
      report.comments.external.each do |comment|
        @params = params.deep_merge(
          comments: [{
            user: build_user_data(comment.author),
            message: comment.message
          }]
        )
      end
    end

    def adds_status_data
      @params = params.merge(
        status: {
          name: report.status.title
        }
      )
    end

    def build_user_data(user)
      {
        name: user.name,
        email: user.email,
        phone: user.phone,
        document: user.document,
        address: user.address,
        address_additional: user.address_additional,
        postal_code: user.postal_code,
        district: user.district
      }
    end

    def external_category_id
      Webhook.external_category_id(report.category)
    end

    def report?
      Webhook.report?(report.category)
    end

    def solicitation?
      Webhook.solicitation?(report.category)
    end

    def serialize_images(images)
      images.map do |image|
        if image.image && image.image.respond_to?(:read)
          {
            data: Base64.encode64(image.image.read),
            :'mime-type' => 'image/png'
          }
        end
      end
    rescue => e
      ErrorHandler.capture_exception(e)
      []
    end
  end
end
