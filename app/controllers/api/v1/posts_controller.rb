module Api
  module V1
    class PostsController < Api::V1::ApiController
      before_action :set_post, only: [:update]
      before_action :active?, only: [:create, :update]
      def index
        @pagy, posts = pagy(Post.where('status IN (1,4)')
                       .order(created_at: :desc)
                       .includes(user: [:state, :district, { profile_attachment: :blob }], images_attachments: :blob))
        if posts.exists?
         posts = PostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data], pagy_links: pagy_metadata(@pagy) })
        else
          render_json(t('post.index.error'))
        end
      end

      def listing_from
        limit = params[:limit].presence ||  6
        posts =  params[:post_id].present? ? Post.where("status IN (1,4) AND posts.id < ?", params[:post_id] ) : Post.where('status IN (1,4)')
        posts = posts.order(created_at: :desc)
                     .includes(user: [:state, :district, { profile_attachment: :blob }], images_attachments: :blob).limit(limit)                
        if posts.exists?
          posts = PostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data]} )
        else
          render_json(t('post.index.error'))
        end
      end

      def create
        attachements = []
        if post_params[:images].present?
          post_params[:images].each do |img|
            p ":::::::::::::::::::::::::::::#{img['c_type']}::::::::::::::#{img['filename']}"
            attachements << {
              io: StringIO.new(Base64.decode64(img['base64'])),
              content_type: img['c_type'],
              filename: img['filename']
            }
          end
        end
        post = Post.new(post_params.except(:images).merge(user: current_user, images: attachements))
        if post.valid?
          PostCreateJob.perform_later(post_params.except(:images), post_params[:images], current_user)
          render_json(t('post.create.message'))
        else
          render_422(post.errors.messages)
        end
      end

      def show
        post = Post.find_by(id: params[:id])
        return render_404(t('post.destroy.error')) unless post.present? && !post.deleted?

        post = PostSerializer.new(post, { params: { current_user: current_user } }).serializable_hash
        render_json(t('post.index.message'), { post: post })
      end

      def image_wise_measurement
        post = Post.find(params[:post_id])
        return render_404(t('post.destroy.error')) unless post.present? && !post.deleted?

        post = ListingFromPostSerializer.new(post, { params: { current_user: current_user } }).serializable_hash
        render_json(t('post.index.message'), { post: post })
      end

      def update
        @post.assign_attributes(post_params.except(:images, :remove))
        if @post.valid?
          new_images_count = post_params[:images].present? ? post_params[:images].compact_blank.count : 0
          remove_images_count = post_params[:remove].present? ? post_params[:remove].compact_blank.count : 0
          images = @post.images.count + new_images_count - remove_images_count
          return render_422({ images: t('activerecord.errors.messages.max_file') }) if images > 5

          attachements = add_attachments(post_params[:images], @post)
          remove_attachments(post_params[:remove])
          @post.images.attach(attachements)
          @post.update(post_params.except(:images, :remove))
          render_json(t('post.update.success'))
        else
          render_422(@post.errors.messages)
        end
      end

      def view_posts
        admin = AdminUser.first if params[:user_id] == 'admin'
        user = User.find_by(id: params[:user_id])
        return render_404(t('user.show.error')) unless user.present? || admin.present?

        posts = user.present? ? user.posts.approved : Post.admin

        posts = case params[:type]
                when 'content'
                  posts.content_post_type.order(created_at: :desc)
                when 'post'
                  posts.post_post_type.order(created_at: :desc)
                else
                  return render_401 unless user == current_user

                  user.posts.where.not(status: 3).order(created_at: :desc)
                end

        if posts.present?
          @pagy, posts = pagy(posts.includes(user: [:state, :district, { profile_attachment: :blob }],
                                             images_attachments: :blob), items: 12)
          posts = PostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data], pagy_links: pagy_metadata(@pagy) })
        else
          render_json(t('post.index.error'))
        end
      end

      def listing_view_posts 
        admin = AdminUser.first if params[:user_id] == 'admin'
        user = User.find_by(id: params[:user_id])
        return render_404(t('user.show.error')) unless user.present? || admin.present?

        posts = user.present? ? user.posts.approved : Post.admin

        posts = case params[:type]
                when 'content'
                  posts.content_post_type.order(created_at: :desc)
                when 'post'
                  posts.post_post_type.order(created_at: :desc)
                else
                  return render_401 unless user == current_user

                  user.posts.where.not(status: 3).order(created_at: :desc)
                end
        limit = params[:limit].presence || 6
        posts = params[:post_id].present? ? posts.where('posts.id < ?', params[:post_id]).limit(limit) : posts.limit(limit)

        if posts.present?
          posts = posts.includes(user: [:state, :district, { profile_attachment: :blob }],
                                             images_attachments: :blob)
          posts = ListingFromPostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data] })
        else
          render_json(t('post.index.error'))
        end
      end

      def crop_wise_post
        return render_400(t('post.crop_wise_post.message')) unless params[:crop_id].present?

        @pagy, posts = pagy(Post.where("status IN (1,4) AND array[#{params[:crop_id]}] && posts.tags")
                       .order(Arel.sql('case status when 4 then 1 when 2 then 2 end'))
                       .order(created_at: :desc)
                       .includes(user: [:state, :district, { profile_attachment: :blob }], images_attachments: :blob))
        if posts.exists?
          posts = PostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data], pagy_links: pagy_metadata(@pagy) })
        else
          render_json(t('post.index.error'))
        end
      end

      def listing_crop_wise_post
        return render_400(t('post.crop_wise_post.message')) unless params[:crop_id].present?
        limit = params[:limit].presence || 6

        posts =  params[:post_id].present? ? Post.where("status IN (1,4) AND array[#{params[:crop_id]}] && posts.tags AND posts.id < ?", params[:post_id] ) : Post.where("status IN (1,4) AND array[#{params[:crop_id]}] && posts.tags")

        posts = posts.order(created_at: :desc).includes(user: [:state, :district, { profile_attachment: :blob }], images_attachments: :blob).limit(limit)

        if posts.exists?
          posts = ListingFromPostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data] })
        else
          render_json(t('post.index.error'))
        end
      end

      def destroy
        post = Post.where.not(status: 3).find_by(id: params[:id])
        return render_404(t('post.destroy.error')) unless post.present?

        if current_user == post.user
          post.update(status: 3)
          render_json(t('post.destroy.message'))
        else
          render_401
        end
      end
      
      def listing_from_post
        block_user_ids = []
        limit = params[:limit].presence ||  6
        posts =  params[:post_id].present? ? Post.where("status IN (1,4) AND posts.id < ?", params[:post_id] ) : Post.where('status IN (1,4)')
        block_user_ids << current_user.blocked_users.pluck(:blocked_user_id)
        block_user_ids << User.where(status: "block").pluck(:id)
        block_user_ids = block_user_ids.flatten.uniq
        posts = posts.where.not(user_id:  block_user_ids).or(posts.where(user_id: nil))
        posts = posts.order(created_at: :desc)
                     .includes(user: [:state, :district, { profile_attachment: :blob }], images_attachments: :blob).limit(limit)                
        if posts.exists?
          posts = ListingFromPostSerializer.new(posts, { params: { current_user: current_user } }).serializable_hash
          render_json(t('post.index.message'), { posts: posts[:data]} )
        else
          render_json(t('post.index.error'))
        end 
      end
      
      private

      def active?
        return render_json(t('post.check.message')) if current_user.status == 'block'
      end

      def set_post
        @post = Post.find_by(id: params[:id])
        return render_401 unless @post.user == current_user
        return render_401(t('post.update.error')) if @post.approved?

        old_count = @post.images.count
        remove = post_params[:remove].present? ? post_params[:remove].count : 0
        add = post_params[:images].present? ? post_params[:images].count : 0
        count = old_count - remove + add
        return render_422([{ images: [t('activerecord.errors.messages.max_file')] }]) if count > 5
      end

      def post_params
        params.require(:post).permit(:discription, remove: [], images: %i[c_type filename base64], tags: [])
      end

      def update_post_params
        params.require(:post).permit(:discription, remove: [], images: [], tags: [])
      end

      def add_attachments(images, post)
        attachements = []
        return unless images.present?

        user_name = "#{post.user.first_name}_#{post.user.last_name}"
        images.each do |img|
          if Rails.env.production?
            path = img['c_type'].include?('image') ? 'posts/images' : 'posts/videos'
          else
            path = img['c_type'].include?('image') ? 'staging/posts/images' : 'staging/posts/videos'
          end
          attachements << {
            io: StringIO.new(Base64.decode64(img[:base64])),
            content_type: img[:content_type],
            filename: img[:filename],
            key: "#{path}/#{DateTime.now.to_i}_#{user_name}_#{img['filename']}"
          }
        end
        attachements
      end

      def remove_attachments(remove)
        return unless remove.present?

        remove.each do |url|
          blob = ActiveStorage::Blob.find_by(key: url[/[^\?]+/].split('.com/'))
          blob.attachments.first.purge if blob.present?
        end
      end
    end
  end
end
