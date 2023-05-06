class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    if current_user.class.to_s == 'User'
      stream_from "user_#{current_user.id}"
    else
      stream_from 'admin'
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
