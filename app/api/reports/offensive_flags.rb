module Reports
  module OffensiveFlags
    class API < Base::API
      helpers do
        def load_item
          Reports::Item.find(params[:id])
        end
      end

      namespace 'items/:id/offensive' do
        desc 'Mark report as offensive'
        put do
          authenticate!

          Reports::FlagItemAsOffensive.new(current_user, load_item).flag!

          {
            message: I18n.t(:'reports.items.offensive.flag.success')
          }
        end

        desc 'Remove offensive flag from report'
        delete do
          authenticate!

          item = load_item
          validate_permission!(:edit, item)

          Reports::FlagItemAsOffensive.new(current_user, item).unflag!

          {
            message: I18n.t(:'reports.items.offensive.unflag.success')
          }
        end
      end

      # Errors
      rescue_from Reports::FlagItemAsOffensive::UserAlreadyReported do |_e|
        rack_response({
          error: I18n.t(:'reports.items.offensive.error.already_reported'),
          type: 'model_validation'
        }.to_json, 400)
      end

      rescue_from Reports::FlagItemAsOffensive::UserReachedReportLimit do |_e|
        rack_response({
          error: I18n.t(:'reports.items.offensive.error.limit_reached'),
          type: 'model_validation'
        }.to_json, 400)
      end
    end
  end
end
