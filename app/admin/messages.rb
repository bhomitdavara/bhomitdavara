ActiveAdmin.register Message do
  menu false

  collection_action :read_message, method: :get do
    @conversation = Conversation.find_by(id: params[:conversation_id])
    set_notification_to_read
  end

  controller do
    def create
      message = Message.new(sender: AdminUser.first, conversation_id: params[:conversation_id], attachements: params[:attachements])
      if message.valid?
        if params[:attachements].present?
          attachements = []
          params[:attachements].compact_blank.each do |img|
            attachements << MediaService.new.upload_multiple_media(img, 'messages')
          end
          message.attachements = attachements
        end
        message.save
        redirect_to admin_path(params[:conversation_id])
      else
        redirect_to admin_path(params[:conversation_id]), notice: 'Please select file OR File type is not supported'
      end
    end

    def set_notification_to_read
      notification = @conversation.notifications_as_conversation.where(recipient: AdminUser.first).unread
      notification.update_all(read_at: Time.now)
    end
  end
end
