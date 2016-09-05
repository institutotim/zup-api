class MessageSender
  def initialize(user, chattable_params)
    @user = user
    @chattable_params = chattable_params
  end

  def send(text, kind)
    message = create_message(text, kind)
    notify_mentioned_users(message)

    message
  end

  private

  def create_message(text, kind)
    message = {
      text: text,
      kind: kind.to_s
    }

    message.merge!(@chattable_params)

    @user.chat_messages.create!(message)
  end

  def notify_mentioned_users(message)
    mentioned = get_mentioned_users(message.text)

    notification = {
      title: "Você foi mencionado por #{@user.name}",
      description: read_more(message.text, 80),
      notificable_id: message.id,
      notificable_type: 'ChatMessage'
    }

    Notify.perform_async(mentioned, notification)
  end

  def get_mentioned_users(text)
    text.scan(/\@\[([1-9][0-9]*):.*\]/).flatten.map(&:to_i).uniq
  end

  def read_more(text, limit)
    summary = text[0..limit]
    summary << '...' if summary.length > 80
    summary
  end
end
