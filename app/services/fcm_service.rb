class FcmService < ApplicationService
  require 'fcm'

  def push_notification(devise_ids, message, image, id, user = 'Admin')
    fcm_client = FCM.new(ENV['FCM_SEVER_KEY'])
    notification = {}
    notification.merge!(title: user, sound: 'default')
    notification.merge!(body: message) if message.present?
    notification.merge!(image: image) if image.present?
    options = { priority: 'high',
                data: { id: id } }
    options.merge!(notification: notification)
    registration_ids = devise_ids
    registration_ids.each_slice(20) do |registration_id|
      response = fcm_client.send(registration_id, options)
      puts "FCM response ------------------------------> #{response}"
    end
  end
end
