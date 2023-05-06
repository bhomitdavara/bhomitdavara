class Message < ApplicationRecord
  include ApplicationHelper
  belongs_to :conversation
  belongs_to :sender, polymorphic: true
  has_noticed_notifications method_name: 'Notification'
  delegate :user, to: :conversation
  before_destroy :delete_notification

  after_create_commit do
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current user -----------> #{conversation.user.inspect}"
    message = ActiveAdmin::Chat::MessagePresenter.new(self)
    ActiveAdmin::Chat::AdminChannel.broadcast_to(conversation, message) unless admin || attachements.attached?

    msg = MessageSerializer.new(self).serializable_hash[:data]
    ActionCable.server.broadcast "conversations_#{conversation.id}", msg
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{msg['attributes']}"
    count = conversation.notifications_as_conversation.where(type: MessageNotification.name,
                                                             recipient: conversation.user).unread.count
    ActionCable.server.broadcast "user_#{conversation.user_id}", { count: count + 1 } if admin
    msg = content.present? ? content : ''

    count = conversation.notifications_as_conversation.where(type: MessageNotification.name,
                                                             recipient: AdminUser.first).unread.count
    notify_recipient

    conversations = Conversation.joins(:messages).order('messages.created_at': :desc).includes(:user).uniq
    
    conversations_list = []
    conversations.each do |conversation| 
      unread = conversation.notifications_as_conversation.where(type: MessageNotification.name,
                                                             recipient: AdminUser.first).unread

      conversations_list << { id: conversation.id, count: unread.count, email:  conversation.user.email }                                             
    end
    
    unless admin
      ActionCable.server.broadcast 'admin',
                                   { content: msg, user: "#{sender.first_name} #{sender.last_name}",
                                     count: count, conversation_id: conversation_id, conversations: conversations_list }
    end
  end

  after_create_commit :send_notification
  has_many_attached :attachements

  validate :message_validate
  validates :attachements, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg', 'video/mp4', %r{\Avideo/.*\z}, %r{\Aaudio/.*\z}],
                                           message: :bad_post }
  validates_each :attachements do |record, _attr, _value|
    record.attachements.each do |attach|
      record.errors.add(:attachements, :too_large) if attach.content_type.starts_with?('image/') && attach.blob.byte_size > 5_000_000
      record.errors.add(:attachements, :too_large_v) if attach.content_type.starts_with?('video/') && attach.blob.byte_size > 40_000_000
    end
  end

  def admin
    sender_type == 'AdminUser'
  end

  def attachements_url
    images = []
    audios =  []
    videos = []
    attachements.each do |attachement|
      public_url = public_url(attachement)
      if public_url.include?('messages/image')
        images << public_url
      elsif public_url.include?("messages/audios")
        audios << public_url
      else
        videos << public_url
      end
    end
 
    { images: images.compact, videos: videos.compact, audio: audios.compact }
  end

  private

  def message_validate
    errors.add(:content, :bad_message) unless content.present? || attachements.attached?
  end

  def notify_recipient
    notification = MessageNotification.with(message: self, conversation: conversation)
    user = admin ? conversation.user : AdminUser.first
    notification.deliver_later(user)
  end

  def send_notification
    return unless admin

    devise_ids = conversation.user.user_tokens.where(login: true).pluck(:devise_id)
    p "----------------------------------> #{devise_ids}"
    PushNotificationJob.perform_later(devise_ids.uniq, content, public_url(attachements&.first), conversation_id)
    # FcmService.new.push_notification(devise_ids.uniq, content, attachements&.first&.url, conversation_id)
  end

  def delete_notification
    notifications_as_message.destroy_all
  end
end
