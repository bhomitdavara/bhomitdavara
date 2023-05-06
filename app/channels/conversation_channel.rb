class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "conversations_#{current_user.conversation.id}"
  end

  def unsubscribed
    stop_all_streams
  end

  def receive(data)
    conversation = Conversation.find_or_create_by(user_id: current_user.id)
    # p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{dhfj}"

    attachements = []
    data['attachements'].each do |img|
      user_name = "#{current_user.first_name}_#{current_user.last_name}"
      attachements << MediaService.new.upload_media_via_api(img, 'messages', user_name)
    end
    message = Message.new(content: data['content'], sender: current_user, conversation: conversation, attachements: attachements)
    message.save
    # message = Message.new(content: data['content'], attachements: data['attachements'], sender: current_user, conversation: conversation)
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{message.errors.messages}" unless message.save
  end

  def read(data)
    message = Message.find_by(id: data['id'])
    conversation = message.conversation
    notification = conversation.notifications_as_conversation.where(recipient: current_user).unread
    notification.update_all(read_at: Time.now)

    ActionCable.server.broadcast "user_#{current_user.id}", { count: 0 }
  end
end
