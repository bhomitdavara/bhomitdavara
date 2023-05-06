module Api
  module V1
    class MessagesController < Api::V1::ApiController
      def index
        @conversation = Conversation.find_or_create_by(user_id: current_user.id)
        # unread = @conversation.notifications_as_conversation.where(recipient: current_user).unread.first
        # id = unread.present? ? unread.params[:message].id : 0
        set_notification_to_read

        messages = @conversation.messages.order(:created_at).includes(attachements_attachments: :blob)
        if messages.present?
          messages = MessageSerializer.new(messages).serializable_hash[:data]

          render_json(t('message.index.msg'), { messages: messages })
          # render_json(t('message.index.msg'), { messages: messages, first_unread_id: id })
        else
          render_json(t('message.index.error'))
        end
      end

      def create
        conversation = Conversation.find_or_create_by(user_id: current_user.id)
        message = Message.new(message_params.merge(sender: current_user, conversation: conversation))
        if message.save
          message = MessageSerializer.new(message).serializable_hash[:data]
          # ActionCable.server.broadcast "conversations_#{conversation.id}", message
          render_json(t('message.create.msg'), { message: message })
        else
          render_422(message.errors.messages)
        end
      end

      private

      def set_notification_to_read
        notification = @conversation.notifications_as_conversation.where(recipient: current_user).unread
        notification.update_all(read_at: Time.now)
        ActionCable.server.broadcast "user_#{current_user.id}", { count: 0 }
      end

      def message_params
        params.require(:message).permit(:content, attachements: [])
      end
    end
  end
end
