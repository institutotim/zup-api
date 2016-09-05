module ChatMessages
  class API < Base::API
    DEFAULT_MESSAGES_PER_PAGE = 25

    desc 'List all chat messages of an entity instance'
    paginate per_page: DEFAULT_MESSAGES_PER_PAGE
    get '/:chattable_type/:chattable_id/chat' do
      authenticate!

      query_params = {
        chattable_type: params[:chattable_type].classify,
        chattable_id: params[:chattable_id]
      }

      messages = ChatMessage.where(query_params).order('created_at DESC')

      {
        messages: ChatMessage::Entity.represent(paginate(messages), only: return_fields)
      }
    end

    desc 'Create a chat_message'
    params do
      requires :text,           type: String,  desc: 'ChatMessage content'
      requires :chattable_type, type: String,  desc: 'Associated entity type'
      requires :chattable_id,   type: Integer, desc: 'Associated entity ID'
    end
    post '/chat/messages' do
      authenticate!

      chattable_params = {
        chattable_type: safe_params[:chattable_type].classify,
        chattable_id: safe_params[:chattable_id]
      }

      chat_message = MessageSender.new(current_user, chattable_params).send(safe_params[:text], :user)

      { message: 'Chat message created successfully', chat_message: ChatMessage::Entity.represent(chat_message, only: return_fields) }
    end
  end
end
