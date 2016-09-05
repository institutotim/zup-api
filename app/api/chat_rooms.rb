module ChatRooms
  class API < Base::API
    ROOMS_PER_PAGE = 25

    resources :chat_rooms do
      desc 'List all chat rooms that the logged user can see'
      paginate per_page: ROOMS_PER_PAGE
      params do
        optional :query, type: String, desc: 'Query of search'
      end
      get do
        authenticate!
        validate_permission!(:view, ChatRoom)

        chat_rooms = if user_permissions.can?(:manage, ChatRoom)
                       ChatRoom.all
                     else
                       ChatRoom.where(id: user_permissions.chat_rooms_visible)
                     end

        chat_rooms = chat_rooms.order('created_at DESC')

        if safe_params[:query].present?
          chat_rooms = chat_rooms.search(safe_params[:query])
        end

        {
          chat_rooms: ChatRoom::Entity.represent(paginate(chat_rooms))
        }
      end

      desc 'Create a chat_room'
      params do
        requires :title, type: String,  desc: 'Title of the chat room'
      end
      post do
        authenticate!

        validate_permission!(:manage_chat_rooms, ChatRoom)

        chat_room_params = safe_params.permit(:title)
        chat_room_params[:namespace_id] = app_namespace_id

        chat_room = ChatRoom.create!(chat_room_params)

        {
          message: I18n.t(:'api.chat_rooms.create.success'),
          chat_room: ChatRoom::Entity.represent(chat_room)
        }
      end

      desc 'Show a chat_room'
      get ':id' do
        authenticate!

        chat_room = ChatRoom.find(safe_params[:id])
        validate_permission!(:view, chat_room)

        {
          chat_room: ChatRoom::Entity.represent(chat_room)
        }
      end

      desc 'Update a chat_room'
      params do
        requires :id,    type: String,  desc: 'ID of the chat room'
        requires :title, type: String,  desc: 'Title of the chat room'
      end
      put ':id' do
        authenticate!
        validate_permission!(:manage_chat_rooms, ChatRoom)

        chat_room_params = safe_params.permit(:id, :title)

        chat_room = ChatRoom.find(chat_room_params[:id])
        chat_room.update!(chat_room_params)

        {
          message: I18n.t(:'api.chat_rooms.update.success'),
          chat_room: ChatRoom::Entity.represent(chat_room)
        }
      end

      desc 'Delete a chat_room'
      delete ':id' do
        authenticate!
        validate_permission!(:manage_chat_rooms, ChatRoom)

        ChatRoom.find(params[:id]).destroy

        {
          message: I18n.t(:'api.chat_rooms.delete.success')
        }
      end
    end
  end
end
