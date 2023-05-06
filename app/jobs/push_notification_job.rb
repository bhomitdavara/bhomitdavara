class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(devise_ids, discription, image, id, user = 'Admin')
    FcmService.new.push_notification(devise_ids, discription, image, id, user)
  end
end
