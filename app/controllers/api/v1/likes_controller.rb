module Api
  module V1
    class LikesController < Api::V1::ApiController
      def create
        like = Like.find_or_initialize_by(post_id: params[:post_id], user: current_user)
        like.liked = like.liked ? false : true
        if like.save
          like = LikeSerializer.new(like).serializable_hash
          render_json(t('like.create.message'), like[:data])
        else
          render_422(like.errors.messages)
        end
      end

      private

      def like_params
        params.require(:like).permit(:post_id)
      end
    end
  end
end
