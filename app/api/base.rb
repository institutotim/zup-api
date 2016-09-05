module Base
  class API < Grape::API
    def self.inherited(subclass)
      super

      subclass.instance_eval do
        rescue_from :all do |e|
          ErrorHandler.capture_exception(e, :error, env['api.endpoint'])

          rack_response({ error: e.message, type: 'unknown' }.to_json, 400)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          res = { error: {}, type: 'params' }

          fail(e) if ENV['RAISE_ERRORS']

          e.errors.each do |field_name, error|
            res[:error].merge!(field_name[0] => error.map(&:to_s))
          end

          rack_response(res.to_json, 400)
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          ErrorHandler.capture_exception(e, :info)

          rack_response({ error: e.message, type: 'not_found' }.to_json, 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          ErrorHandler.capture_exception(e, :info)

          rack_response({ error: e.record.errors.messages.as_json, type: 'model_validation' }.to_json, 400)
        end

        rescue_from ActiveRecord::RecordNotUnique do |e|
          ErrorHandler.capture_exception(e, :info)

          rack_response({ error: I18n.t(:'errors.messages.unique'), type: 'model_validation' }.to_json, 400)
        end

        rescue_from Reports::ValidateVersion::VersionMismatch do |e|
          ErrorHandler.capture_exception(e, :info)

          rack_response({ error: I18n.t(:'errors.messages.version_mismatch'), type: 'version_mismatch' }.to_json, 400)
        end

        before do
          Thread.current[:current_namespace] = nil

          # If a token comes with the request, let's validate it
          # before doing anything, if it's invalid let's return an error
          unless skip_token_endpoints.include?(current_route)
            validates_app_token! if app_token
          end

          unless skip_namespace_endpoints.include?(current_route)
            validate_app_namespace!
          end
        end

        after do
          Thread.current[:current_namespace] = nil
        end

        format :json
        default_format :json

        formatter :json, -> (object, _env) { Oj.dump(object) }

        helpers do
          def app_token
            # TODO: Remove this BS
            return false if (headers['X-App-Token'].blank? || headers['X-App-Token'] == 'null') && env['X-App-Token'].blank? && params[:token].blank?
            @app_token ||= headers['X-App-Token'] || env['X-App-Token'] || params[:token]
          end

          def app_namespace_id
            @app_namespace_id ||= headers['X-App-Namespace'] || env['X-App-Namespace'] ||
              params[:namespace] || params[:namespace_id]
          end

          def skip_namespace_endpoints
            %w(/namespaces /namespaces/:id /users/unsubscribe/:token /reset_password
               /recover_password /authenticate /sign_out /me /terminology
               /reports/webhooks /reports/webhooks/:uuid /settings /settings/:name
               /utils/city-boundary/validate /users /feature_flags)
          end

          def skip_token_endpoints
            %w(/users/unsubscribe/:token /reset_password /recover_password)
          end

          def validates_app_token!
            @current_user ||= User.authorize(app_token)
            authenticate!
          end

          def validate_app_namespace!
            if valid_namespace?(app_namespace_id)
              Thread.current[:current_namespace] = app_namespace_id
              Grape::Entity.class_variable_set(:@@namespace_id, app_namespace_id)
            else
              error!({ error: I18n.t(:invalid_namespace), type: 'invalid_namespace' }, 422)
            end
          end

          def valid_namespace?(namespace_id = nil)
            if current_user
              permissions = user_permissions
              namespaces = permissions.namespaces_visible

              permissions.can?(:manage, Namespace) || namespaces.include?(namespace_id.to_i)
            else
              Namespace.exists?(id: namespace_id.to_i)
            end
          end

          def current_route
            route.route_path.gsub('(.:format)', '').gsub('(.json)', '')
          end

          def set_current_user(user)
            @current_user = user
          end

          def current_user
            @current_user
          end

          def current_namespace
            @current_namespace ||= Namespace.find(app_namespace_id)
          end

          def authenticate!
            unless current_user
              error!('Unauthorized, Invalid or expired token', 401)
            end
          end

          def validate_permission!(action, model)
            if current_user
              permissions = user_permissions

              unless permissions.can?(action, model)
                table_name = if model.respond_to?(:table_name)
                               model.table_name
                             else
                               model.class.table_name
                             end

                action = I18n.t(action.to_sym)
                table  = I18n.t(table_name.to_sym)

                error!({ error: I18n.t(:permission_denied, action: action, table_name: table), type: 'invalid_permission' }, 403)
              end
            end
          end

          def user_permissions
            @user_permissions ||= UserAbility.for_user(current_user)
          end

          def safe_params
            ActionController::Parameters.new(params)
          end

          # This should go to a middleware
          def return_fields
            ReturnFieldsParams.new(params[:return_fields]).to_array
          end
        end
      end
    end # --initialize
  end
end
