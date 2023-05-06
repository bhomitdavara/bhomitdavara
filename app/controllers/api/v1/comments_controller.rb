module Api
  module V1
    class CommentsController < Api::V1::ApiController
      before_action :set_post, only: %i[destroy index list_of_comments]
      before_action :set_attribute, only: %i[index create list_of_comments]

      def index
        comments = []
        @post.comments.where('comments.is_active = ? AND comments.status != ?', true, 1 ).includes(user: [:district, :state, { profile_attachment: :blob }]).each do |comment|
          user = comment.user
          user = { id: comment.user_id.to_s, name: "#{user.first_name} #{user.last_name}", profile_url: user.profile_url,
                  village: user.village, district: user.district[@name], state: user.state[@name] }
          comments << { id: comment.id.to_s, discription: comment.discription, user: user, created_at: comment.created_at,
                        sub_comments: [] }
          sub_comment = []
          comment.sub_comments.where(is_active: true).includes(user: { profile_attachment: :blob }).each do |dis|
            user = dis.user
            user = { id: dis.user_id.to_s, name: "#{user.first_name} #{user.last_name}", profile_url: user.profile_url,
                     village: user.village, district: user.district[@name], state: user.state[@name] }
            sub_comment << { id: dis.id.to_s, discription: dis.discription, created_at: dis.created_at, user: user }
          end

          comments.last['sub_comments'] = sub_comment
        end

        if comments.present?
          render_json(t('comment.index.message'), { comments: comments })
        else
          render_json(t('comment.index.error'))
        end
      end
     
      def list_of_comments
        comments = []
        @post.comments.where(is_active: true).includes(user: [:district, :state, { profile_attachment: :blob }]).each do |comment|
          if comment.user?
            user = comment.user
            user = { id: comment.user_id.to_s, name: "#{user.first_name} #{user.last_name}", profile_url: user.profile_url,
                    village: user.village, district: user.district[@name], state: user.state[@name] }
            comments << { id: comment.id.to_s, discription: comment.discription, user: user, created_at: comment.created_at,
                          sub_comments: [] }

          elsif comment.admin?

            comments << { id: comment.id.to_s, discription: comment.discription, admin: 'admin', created_at: comment.created_at,
                          sub_comments: [] }
          end
          sub_comment = []
          comment.sub_comments.where(is_active: true).includes(user: { profile_attachment: :blob }).each do |dis|
            # if dis.user?
              user = dis.user
              user = { id: dis.user_id.to_s, name: "#{user.first_name} #{user.last_name}", profile_url: user.profile_url,
                      village: user.village, district: user.district[@name], state: user.state[@name] }
              sub_comment << { id: dis.id.to_s, discription: dis.discription, created_at: dis.created_at, user: user }
             
            # elsif dis.admin?
            #   sub_comment << { id: dis.id.to_s, discription: dis.discription, created_at: dis.created_at, admin: 'admin' }
            # end
          end

          comments.last['sub_comments'] = sub_comment
        end

        if comments.present?
          render_json(t('comment.index.message'), { comments: comments })
        else
          render_json(t('comment.index.error'))
        end
      end

      def create
        comment = Comment.create(comment_params.merge(post_id: params[:post_id], user: current_user))
        if comment.save
          comment = CommentSerializer.new(comment, { params: { name: @name } }).serializable_hash
          render_json(t('comment.create.message'), comment[:data])
        else
          render_422(comment.errors.messages)
        end
      end

      def destroy
        comment = @post.comments.find_by(id: params[:id])
        return render_404(t('comment.destroy.error')) unless comment.present?

        if current_user == comment.user || current_user.posts.include?(@post)
          comment.destroy
          render_json(t('comment.destroy.message'))
        else
          render_401
        end
      end

      private

      def set_post
        @post = Post.find_by(id: params[:post_id])
        return render_404('post not found') unless @post.present?
      end

      def comment_params
        params.require(:comment).permit(:discription)
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
