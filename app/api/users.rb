module Users
  class API < Base::API
    USERS_SHOWN_ON_AUTOCOMPLETE = 5

    desc 'Authenticate user and return a valid access token'
    params do
      requires :email, type: String, desc: "User's email address"
      requires :password, type: String, desc: "User's password"
      optional :device_token, type: String, desc: 'The device token if registration is from mobile'
      optional :device_type, type: String, desc: 'Could be ios or android'
    end
    post :authenticate do
      device = (params[:device_type] ? :mobile : :other)
      user = User.authenticate(params[:email], params[:password], device)

      if user
        set_current_user(user)

        if params[:device_token] || params[:device_type]
          user_params = safe_params.permit(:device_token, :device_type)
          user.update(user_params)
        end

        accessible_namespaces_ids = user_permissions.namespaces_visible

        {
          user: User::Entity.represent(
                  user,
                  only: return_fields,
                  display_type: 'full',
                  display_groups: true
                ),
          token: user.last_access_key,
          acessible_namespaces: accessible_namespaces_ids.size > 0 ? Namespace.where(id: accessible_namespaces_ids) : []
        }
      else
        status(401)
        { error: 'E-mail e senha incorretos ou não existem no sistema' }
      end
    end

    desc 'Logout: invalidate access token'
    params do
      requires :token, type: String, desc: 'The access token'
    end
    delete :sign_out do
      authenticate!

      if safe_params[:token].present?
        access_key = current_user.access_keys.find_by!(key: safe_params[:token])
        access_key.expire!
      else
        current_user.access_keys.active.each(&:expire!)
      end

      { message: 'Token invalidado com sucesso!' }
    end

    # Password recovery
    desc "Recover user's password"
    params do
      requires :email, type: String, desc: "The user's email address"
      optional :panel, type: Boolean, desc: 'Password recovery triggered from panel'
    end
    put :recover_password do
      User.request_password_recovery(params[:email], params[:panel])

      { message: 'E-mail de recuperação de senha enviado com sucesso!' }
    end

    desc "Resets user's password"
    params do
      requires :token, type: String, desc: 'The password reset token'
      requires :new_password, type: String, desc: 'The new password for the account'
      requires :new_password_confirmation, type: String, desc: 'The password confirmation'
    end
    put :reset_password do
      if User.reset_password!(params[:token], params[:new_password], params[:new_password_confirmation])
        { message: 'Senha alterada com sucesso!' }
      else
        { message: 'Sessão para resetar a senha está inválida ou expirado.', error: true }
      end
    end

    desc 'Shows authenticated info'
    get :me do
      authenticate!

      acessible_namespaces_ids = user_permissions.namespaces_visible

      { user: User::Entity.represent(current_user,
                                     only: return_fields,
                                     display_type: 'full'
                                    ),
        acessible_namespaces: acessible_namespaces_ids.size > 0 ? Namespace.find(acessible_namespaces_ids) : []
      }
    end

    desc 'Destroy current user account'
    delete :me do
      authenticate!
      validate_permission!(:delete, current_user)
      current_user.disable!

      { message: 'Conta deletada com sucesso.' }
    end

    # Users CRUD
    resources :users do
      desc 'List all registered users'
      paginate per_page: 25
      params do
        optional :name, type: String, desc: 'The name of the user to search for'
        optional :email, type: String, desc: 'The email of the user to search for'
        optional :groups, type: String, desc: 'Groups ids, format: "1,2,3"'
        optional :query, type: String, desc: 'Query to search users by name, document or email'
        optional :filter, type: String, desc: 'Should filter the result instead of searching?'
        optional :disabled, type: Boolean, desc: 'Return disabled users'
        optional :global_namespaces, type: Boolean,
          desc: 'Return users of current namespace and global namespace'
        optional :ignore_namespaces, type: Boolean, desc: 'Ignore namespace system'
      end
      get do
        authenticate!
        validate_app_namespace!

        if safe_params[:groups]
          groups = Group.find(safe_params[:groups].split(','))
        end

        search_params = safe_params.permit(
          :name, :email, :disabled, :query, :global_namespaces, :filter
        )

        search_params[:groups] = groups
        search_params[:namespace_id] = app_namespace_id unless safe_params[:ignore_namespaces]

        users = ListUsers.new(current_user, search_params).fetch
        users = paginate(users.paginate(page: params[:page]))

        {
          users: User::Entity.represent(
            users, display_type: 'full'
          )
        }
      end

      desc 'Create an user'
      params do
        requires :email, type: String, desc: "User's email address used for sign in"
        optional :password, type: String, desc: "User's password"
        optional :password_confirmation, type: String, desc: "User's password confirmation"
        optional :generate_password, type: Boolean, desc: 'Should the API generate a password for this user?'

        requires :name, type: String, desc: "User's name"
        requires :phone, type: String, desc: 'Phone, only numbers'
        optional :commercial_phone, type: String, desc: 'Phone, only numbers'
        optional :skype, type: String, desc: "User's skype username"
        requires :document, type: String, desc: "User's document (CPF), only numbers"
        optional :birthdate, type: Date, desc: "User's birthdate"
        requires :address, type: String, desc: "User's address (with the number)"
        optional :address_additional, type: String, desc: 'Address complement'
        requires :postal_code, type: String, desc: 'CEP'
        requires :district, type: String, desc: "User's neighborhood"
        requires :city, type: String, desc: "User's city"
        optional :groups_ids, type: Array, desc: 'User groups'

        optional :institution, type: String, desc: "User's institution"
        optional :position, type: String, desc: "User's position"

        optional :facebook_user_id, type: Integer, desc: "User's id on facebook"
        optional :twitter_user_id, type: Integer, desc: "User's id on twitter"
        optional :google_plus_user_id, type: Integer, desc: "User's id on G+"

        optional :device_token, type: String, desc: 'The device token if registration is from mobile'
        optional :device_type, type: String, desc: 'Could be `ios` or `android`'

        optional :email_notifications, type: Boolean, desc: 'If the user wants email notification or not'
        optional :namespace_id, type: Integer, desc: 'Namespace ID'
      end
      post do
        user = User.new(
          safe_params.permit(
            :password, :password_confirmation,
            :name, :email, :phone, :commercial_phone, :skype,
            :document, :birthdate, :address, :institution, :position,
            :address_additional, :postal_code, :district,
            :facebook_user_id, :twitter_user_id,
            :google_plus_user_id, :groups_ids,
            :device_token, :device_type, :email_notifications,
            :city, :namespace_id
          )
        )

        if params[:groups_ids].present?
          user.groups = Group.find(params[:groups_ids])

          validate_permission!(:create, user)
        else
          guest_group = Group.guest
          user.groups << guest_group if guest_group
        end

        if params[:generate_password]
          password = user.generate_random_password!
          UserMailer.delay.send_user_random_password(user, password)
        end

        user.namespace_id = params[:namespace_id] || app_namespace_id
        user.save!

        {
          message: 'Usuário criado com sucesso',
          user: User::Entity.represent(user, only: return_fields, display_type: 'full')
        }
      end

      desc 'Shows user info'
      get ':id' do
        user = User.unscoped.find(safe_params[:id])
        { user: User::Entity.represent(user, only: return_fields, display_type: 'full', display_groups: true) }
      end

      desc "Update user's info"
      params do
        optional :current_password, type: String, desc: "Current user's password"
        optional :password, type: String, desc: "User's password"
        optional :password_confirmation, type: String, desc: "User's password confirmation"
        optional :generate_password, type: Boolean, desc: 'Should the API generate a password for this user?'

        optional :name, type: String, desc: "User's name"
        optional :email, type: String, desc: "User's email address"
        optional :phone, type: String, desc: 'Phone, only numbers'
        optional :commercial_phone, type: String, desc: 'Phone, only numbers'
        optional :skype, type: String, desc: "User's skype username"
        optional :document, type: String, desc: "User's document (CPF), only numbers"
        optional :birthdate, type: Date, desc: "User's birthdate"
        optional :address, type: String, desc: "User's address (with the number)"
        optional :address_additional, type: String, desc: 'Address complement'
        optional :postal_code, type: String, desc: 'CEP'
        optional :district, type: String, desc: "User's neighborhood"
        optional :city, type: String, desc: "User's city"
        optional :groups_ids, type: Array, desc: 'User groups'

        optional :institution, type: String, desc: "User's institution"
        optional :position, type: String, desc: "User's position"

        optional :device_token, type: String, desc: 'The device token if registration is from mobile'
        optional :device_type, type: String, desc: 'Could be ios or android'

        optional :email_notifications, type: Boolean, desc: 'If the user wants email notification or not'

        optional :namespace_id, type: Integer, desc: 'Namespace ID'
      end
      put ':id' do
        authenticate!

        user = User.unscoped.find(safe_params[:id])
        validate_permission!(:edit, user)

        user_params = safe_params.permit(
          :email, :current_password, :password,
          :password_confirmation, :name, :phone, :commercial_phone, :skype,
          :document, :birthdate, :address, :institution, :position,
          :address_additional, :postal_code, :district,
          :device_token, :device_type, :email_notifications, :city, :namespace_id
        )

        if params[:generate_password]
          password = user.generate_random_password!
          UserMailer.delay.send_user_random_password(user, password)
        end

        begin
          user.update!(user_params.merge(user_changing_password: current_user))

          if params[:groups_ids]
            user.groups = Group.unscoped.find(params[:groups_ids])
          end

          { message: 'Conta alterada com sucesso.' }
        rescue ActiveRecord::RecordInvalid => e
          Raven.capture_exception(e)

          status 400
          {
            error: user.errors.full_messages.as_json,
            type: 'model_validation'
          }
        end
      end

      desc 'Destroy user account'
      delete ':id' do
        authenticate!
        user = User.find(safe_params[:id])
        validate_permission!(:delete, user)

        user.disable!

        { message: 'Conta deletada com sucesso.' }
      end

      desc 'Enable user account'
      put ':id/enable' do
        authenticate!
        user = User.unscoped.find(safe_params[:id])
        validate_permission!(:edit, user)

        user.enable!

        { message: 'Conta habilitada com sucesso.' }
      end

      desc 'Unsubscribe user from emails'
      params do
        requires :token, type: String, desc: ''
      end
      get 'unsubscribe/:token' do
        result = User.unsubscribe(params[:token])

        if result
          { message: 'Você não receberá mais atualizações no seu e-mail!' }
        else
          { message: 'Usuário não encontrado' }
        end
      end
    end

    desc 'Autocomplete for users on chat'
    params do
      requires :term, type: String, desc: 'The search string for the autocomplete'
    end
    get '/autocomplete/user' do
      authenticate!

      users = User.where(namespace_id: app_namespace_id).search_by_name(safe_params[:term]).reorder(:name).limit(USERS_SHOWN_ON_AUTOCOMPLETE)

      {
        result: User::Entity.represent(users, display_type: 'autocomplete', only: [:id, :name, :mention_string])
      }
    end
  end
end
