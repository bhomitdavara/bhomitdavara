module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include JwtToken
    identified_by :current_user

    def connect
      self.current_user = find_verified_user request.params[:token]
    end

    private

    def find_verified_user(token)
      if token.present?
        data = jwt_decode(token)
        reject_unauthorized_connection if data == 'false'
        verified_user = User.find_by(mobile_no: data['mobile_no'])
      else
        verified_user = env['warden'].user
      end
      p ">>>>>>>>>>>>>>>>>>>>>>>>#{verified_user.inspect}"
      reject_unauthorized_connection unless verified_user

      verified_user
    end
  end
end
