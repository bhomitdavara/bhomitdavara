module Api
  module V1
    class SubCommentsController < Api::V1::ApiController
      before_action :set_comment, only: [:destroy]
      before_action :set_attribute, only: [:create]

      def create
        sub_comment = SubComment.new(comment_params.merge(comment_id: params[:comment_id], user: current_user))
        if sub_comment.save
          comment = SubCommentSerializer.new(sub_comment, { params: { name: @name } }).serializable_hash
          render_json(t('comment.create.message'), comment[:data])
        else
          render_422(sub_comment.errors.messages)
        end
      end

      def destroy
        sub_comment = @comment.sub_comments.find_by(id: params[:id])
        return render_404(t('comment.destroy.error1')) unless sub_comment.present?

        if current_user == sub_comment.user || current_user.posts.include?(@comment.post)
          sub_comment.destroy
          render_json(t('comment.destroy.message'))
        else
          render_401
        end
      end

      private

      def set_comment
        @comment = Comment.find_by(id: params[:comment_id])
        return render_404(t('comment.destroy.error')) unless @comment.present?
      end

      def comment_params
        params.require(:sub_comment).permit(:discription)
      end

      def set_attribute
        if current_user.gujarati?
          @name = 'name_gu'
        elsif current_user.english?
          @name = 'name_en'
        elsif current_user.hindi?
          @name = 'name_hi'
        end
      end
    end
  end
end
