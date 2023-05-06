module ApplicationHelper
  def generate_otp
    # (SecureRandom.random_number(9e5) + 1e5).to_i
    '123456'
  end

  def date_format
    DateTime.now.strftime('%d-%m-%Y')
  end

  def user_name(user)
    "#{user.first_name.titleize} #{user.last_name.titleize}"
  end

  def mobile(mobile_no)
    mobile_no.gsub('+91', '')
  end

  def public_url(image)
    image.present? ? "#{ENV['bucket_url']}/#{image.key}" : ''
  end
end
