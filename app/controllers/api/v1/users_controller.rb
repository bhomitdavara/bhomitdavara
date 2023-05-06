module Api
  module V1
    class UsersController < Api::V1::ApiController
      skip_before_action :authenticate_user!, only: %i[create verify_otp add_user health_check]
      # before_action :authenticate_api!, only: [:dropdown_option]
      include JwtToken
      include ApplicationHelper

      def create
        user = User.find_or_initialize_by(mobile_no: params[:mobile_no])
        user.language = params[:language]
        user.otp = generate_otp
        if user.save
          # user.generate_otp

          # res = TwillioServices.call(user)
          # if res == 'OK'
          #   render_json(t('user.create.message'), { id: user.id.to_s, mobile_no: user.mobile_no })
          # else
          #   render_422(res)
          # end
          render_json(t('user.create.message'), { id: user.id.to_s, mobile_no: user.mobile_no })
        else
          render_422(user.errors.messages)
        end
      end

      def verify_otp
        unless params[:devise_id].present?
          return render json: { status: 'Missing Parameter', code: 422,
                                errors: [], message: 'paramenter devise id missing' }, status: 422
        end

        user = User.find_by(id: params[:id])
        if user&.valid_otp?(params[:otp])
          token = user.user_tokens.find_or_create_by(devise_id: params[:devise_id])
          token.update(login: true)
          user_detail = UserSerializer.new(user).serializable_hash[:data]
          user.update(active: true, otp: nil)
          render_json(t('user.verify_otp.message'), { token: jwt_encode(user, params[:devise_id]), user: user_detail })
        else
          render_203(t('user.verify_otp.error'))
        end
      end

      def add_user
        unless params[:devise_id].present?
          return render json: { status: 'Missing Parameter', code: 422,
                                errors: [], message: 'paramenter devise id missing' }, status: 422
        end
        user = User.find_or_initialize_by(mobile_no: params[:mobile_no], active: true)
        if user.new_record?
          user = user.active? ? user : User.create(mobile_no: params[:mobile_no])
        end

        user.language = params[:language]
        if user.save
          token = user.user_tokens.find_or_create_by(devise_id: params[:devise_id])
          token.update(login: true)
          user_detail = UserSerializer.new(user).serializable_hash[:data]
          render_json(t('user.verify_otp.message'), { token: jwt_encode(user, params[:devise_id]), user: user_detail })
        else
          render_203(user.errors.messages)
        end
      end

      def update
        current_user.assign_attributes(user_params)
        if current_user.valid?
          current_user.update(user_params.except(:profile))
          if user_params[:profile].present?
            profile = MediaService.new.upload_media(user_params[:profile], 'users')
            current_user.profile.attach(profile)
          end
          current_user.user_tokens.update_all(login: false) unless current_user.reload.active
          user = UserSerializer.new(current_user).serializable_hash
          render_json(t('user.update.message'), { user: user[:data] })
        else
          render_422(current_user.errors.messages)
        end
      end

      def show
        user = User.find_by(id: params[:id])
        return render_404(t('user.show.error')) unless user.present?

        user = UserSerializer.new(user).serializable_hash
        render_json(t('user.show.message'), { user: user[:data] })
      end

      def dropdown_option
        states = []
        State.all.includes([:districts]).each do |state|
          states << { id: state.id.to_s, name_en: state.name_en, name_gu: state.name_gu, name_hi: state.name_hi, districts: [] }
          state.districts.each do |dis|
            if states.last['districts'].blank?
              states.last['districts'] = [{ id: dis.id.to_s, name_en: dis.name_en, name_gu: dis.name_gu, name_hi: dis.name_hi }]
            else
              states.last['districts'] << { id: dis.id.to_s, name_en: dis.name_en, name_gu: dis.name_gu, name_hi: dis.name_hi }
            end
          end
        end

        soil_types = []
        SoilType.all.each do |soil_type|
          soil_types << { id: soil_type.id.to_s, name_en: soil_type.name_en, name_gu: soil_type.name_gu,
                          name_hi: soil_type.name_hi }
        end
        render_json(t('user.dropdown_option.message'), eng: { states: states, soil_types: soil_types })
      end

      def logout
        user = current_user
        token = current_user.user_tokens.find_by(devise_id: deviseid)
        token.update(login: false)
        if token.present?
          user = UserSerializer.new(user).serializable_hash[:data]
          render_json('Logout successfully', { user: user })
        else
          render_203('Token is invalid')
        end
      end

      def health_check
        if params[:devise_id].present?
          maintenance = Maintenance.last
          return render_json("This app is now live.", {status: true}) unless maintenance.status
          devise_tokens = []
          devise_tokens << UserToken.where(user_id:  maintenance.allowed_users.compact).pluck(:devise_id)
          devise_tokens << maintenance.devise_tokens.split(',')
          
          if devise_tokens.flatten.include?(params[:devise_id].to_s)
            render_json("You have permission to assess this app", { status: maintenance.status })
          else
            render_json("#{maintenance.message}", { status: false })
          end
        else
          render_404('Devise id is missing!!')
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :profile, :village, :state_id, :district_id,
                                     :soil_type_id, :language, :active, favourite_crops: [])
      end
    end
  end
end
