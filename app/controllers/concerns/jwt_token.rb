module JwtToken
  extend ActiveSupport::Concern

  def jwt_encode(user, devise_id)
    JWT.encode({ mobile_no: user.mobile_no, id: user.id, devise_id: devise_id }, ENV['SECRET_KEY'])
  end

  def jwt_decode(token)
    data = JWT.decode(token, ENV['SECRET_KEY'])[0]
    HashWithIndifferentAccess.new(data)
  rescue JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError
    'false'
  end
end
