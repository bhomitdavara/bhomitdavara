class TwillioServices < ApplicationService
  attr_reader :user

  def initialize(user)
    # super(user)
    @user = user
  end

  def twilio_client
    Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end

  def call
    twilio_client.messages.create(
      to: user.mobile_no,
      messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID'],
      body: "DO NOT SHARE: Your Khedut Mall OTP is #{user.otp}"
    )
    'OK'
  rescue Twilio::REST::RequestError => e
    e.message
  end
end
