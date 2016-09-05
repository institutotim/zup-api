module Reports
  class CreateItemFromWebhook
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def create!
      ActiveRecord::Base.transaction do
        report = Reports::Item.create!(build_reports_params)

        if params[:images]
          report.update_images!(build_images_params(params[:images]))
        end

        report
      end
    end

    private

    def build_reports_params
      reports_params = {}

      category = find_category(params[:external_category_id])
      namespace = Namespace.find(params[:namespace_id])

      # Report params
      reports_params = reports_params.merge(
        external_category_id: params[:external_category_id],
        category: category,
        namespace: namespace,
        is_solicitation: params[:is_solicitation],
        is_report: params[:is_report],
        description: params[:description],
        address: params[:address],
        reference: params[:reference],
        user: create_user(params[:user], namespace),
        from_webhook: true
      )

      if params[:longitude] && params[:latitude]
        reports_params = reports_params.merge(
          position: Reports::Item.rgeo_factory.point(params[:longitude], params[:latitude])
        )
      end

      # Comments params
      comments = params[:comments]

      if comments
        comments.each do |comment|
          reports_params = reports_params.deep_merge(
            comments_attributes: [{
              author: create_user(comment[:user], namespace),
              message: comment[:message],
              from_webhook: true
            }]
          )
        end
      end

      # Find or create status
      status = find_or_create_status!(params[:status], category, namespace)
      reports_params = reports_params.merge(
        reports_status_id: status.id
      )

      reports_params
    end

    def create_user(params, namespace)
      user_params = {
        name: params[:name],
        email: params[:email],
        phone: params[:phone],
        document: params[:document],
        address: params[:address],
        address_additional: params[:address_additional],
        postal_code: params[:postal_code],
        district: params[:district],
        ignore_password_requirement: true,
        from_webhook: true,
        namespace: namespace
      }

      user = User.find_by(email: params[:email])

      if user
        user_params.delete(:email)
        user.update!(user_params)
      else
        user = User.create!(user_params)
      end

      user
    end

    def build_images_params(parameters)
      images = []

      parameters.each do |param|
        images << {
          'content' => param[:data]
        }
      end

      images
    end

    def find_or_create_status!(parameters, category, namespace)
      name = parameters[:name]
      status = Reports::Status.create_with(color: '#cccccc', namespace: namespace)
                              .find_or_create_by!(title: name)

      category.status_categories.create_with(color: '#cccccc').find_or_create_by!(
        reports_status_id: status.id, namespace_id: namespace.id
      )

      status
    end

    def find_category(external_category_id)
      Webhook.zup_category(external_category_id)
    end
  end
end
