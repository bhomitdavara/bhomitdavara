module Api
  module V1
    class ApiController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_user!
      before_action :set_locale, except: %i[health_check]
      include ExceptionHandling
      include JwtToken
      include ApplicationHelper

      attr_reader :current_user, :deviseid

      private

      def set_locale
        I18n.locale = current_user.present? ? current_user.language.slice(0, 2) : params[:language].slice(0, 2)
      end

      def authenticate_user!
        header = request.headers['Authorization']
        return render_401 unless header

        data = jwt_decode(header.split(' ').last)
        if data == 'false'
          render_401
        else
          @deviseid = data[:devise_id]
          user_token = UserToken.find_by(devise_id: @deviseid, user_id: data[:id], login: true)
          @current_user = User.find_by(id: data[:id])
          return render_401 unless user_token.present? && @current_user.present?
        end
      end

      #   def authenticate_api!
      #     header = request.headers['Authorization']
      #     return render_401 unless header

      #     header_token = header.split(' ').last
      #     token = Base64.strict_encode64(date_format)
      #     return render_401 unless token == header_token
      #   end
    end
  end
end
