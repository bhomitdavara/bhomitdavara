ActiveAdmin.register_chat 'Chat' do
  # menu true
  controller do
    def index
      search = params[:search]
      if search
        @conversations = Conversation.joins(:messages, :user).order('messages.created_at': :desc).select("conversations.*, CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) AS name").where("CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) ILIKE :search", search: "%#{search}%").uniq
        @conversations += Conversation.where.missing(:messages).joins(:user).select("conversations.*, CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) AS name") if search.blank?
      else
        @conversations = Conversation.joins(:messages, :user).order('messages.created_at': :desc).select("conversations.*, CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) AS name").uniq
        @conversations += Conversation.where.missing(:messages).joins(:user).select("conversations.*, CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) AS name")
      end
      unread_message
      respond_to do |format|
        format.html
        format.turbo_stream
        format.js
      end
    end

    def show
      @conversations = Conversation.joins(:messages, :user).order('messages.created_at': :desc).select("conversations.*, CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) AS name").uniq # .where("CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) LIKE 'Devangi Kakadiya' AND messages. != NULL").uniq
      @conversations += Conversation.where.missing(:messages).joins(:user).select("conversations.*, CONCAT(INITCAP(users.first_name), ' ', INITCAP(users.last_name)) AS name")
      @conversation = Conversation.find(params[:id])
      set_notification_to_read
      @messages = @conversation.messages.order(:created_at).includes(:sender, attachements_attachments: :blob)
      unread_message
      respond_to do |format|
        format.html
      end
    end

    private

    def set_notification_to_read
      notification = @conversation.notifications_as_conversation.where(recipient: AdminUser.first).unread
      notification.update_all(read_at: Time.now)
    end

    def unread_message
      unread = Notification.unread.where(recipient_type:  'AdminUser')
      @unread_conversation_id = []
      unread.each do |u|
        @unread_conversation_id << u.params[:conversation].id
      end
      @unread_conversation_id = @unread_conversation_id.uniq
    end
  end
end
