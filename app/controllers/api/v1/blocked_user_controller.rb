module Api
  module V1
    class BlockedUserController < Api::V1::ApiController
      def list_of_block_users
        blocked_users = current_user.blocked_users
        if blocked_users.present?
          blocked_users_list = ListOfBlockUsersSerializer.new(blocked_users).serializable_hash
          render_json(blocked_users: blocked_users_list[:data] )
        else
          render_json('Blocked users not found',data = {}, msg_type = 'emptylist')
        end
      end

      def block
        if params[:blocked_user_id]
          unless BlockedUser.where(blocked_user_id: params[:blocked_user_id], user: current_user).present?
            render_json('Blocked the user successfully') if BlockedUser.create(blocked_user_id: params[:blocked_user_id], user: current_user)
          else
            render_404('You are already blocked the user!!!')
          end
        else
          render_400('Parameter is missing!!!')
        end
      end

      def unblock
        if params[:blocked_user_id]
          block_user = BlockedUser.find_by(blocked_user_id: params[:blocked_user_id], user: current_user)
          if block_user.present?
            block_user.destroy
            render_json('Successfully unblocked the user') 
          else
            render_json('This user is not blocked!!!',data = {}, msg_type = 'user not blocked')
          end
        else
          render_400('Parameters are missing!!!')
        end
      end

      def report
        if params[:reported_user_id] && params[:description]
          render_json('Successfully reported the user') if Report.create!(description: params[:description], user: current_user, reported_user_id: params[:reported_user_id])
        else
          render_400('Parameters are missing!!!')
        end
      end
    end
  end
end
