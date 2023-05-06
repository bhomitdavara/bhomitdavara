ActiveAdmin.register Post do
  menu priority: 6
  permit_params :discription, :admin, :status, tags: [], images: []
  filter :user, collection: -> do
    us = []
    User.joins(:posts).select("users.id, CONCAT(users.first_name, ' ', users.last_name) AS name").uniq.each do |u|
      us << [u.name.titleize, u.id]
    end
  end
  filter :discription, label: 'description'
  scope :review, default: true
  scope :approved
  scope :rejected
  scope :admin_post

  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    if post.admin?
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_post_path(post), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_post_path(post),
                       method: :delete,
                       data: { confirm: 'Are you sure delete post?' },
                       class: 'btn btn-danger')
    end

    if post.review? || post.rejected?
      links << link_to(raw("<i class='fas fa-check'></i> Approve Post"), approve_post_admin_post_path(post),
                       method: :post, class: 'btn btn-success')
    end

    if post.review? || post.approved?
      links << link_to(raw("<i class='fas fa-times'></i> Reject Post"), reject_post_admin_post_path(post),
                       method: :patch, class: 'btn btn-danger')
    end
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Post"), new_admin_post_path)
  end

  form do |f|
    inputs 'Post' do
      f.input :discription, label: 'Description', as: :text
      f.input :images, as: :file, input_html: { multiple: true, accept: "image/png, image/jpeg, image/jpg, video/*" }
      if @resource.images.attached?
        image = @resource.images.includes(:blob)

        ul do
          div do
            image.compact.each do |img|
              if img.content_type.include?('image')
                post_url = public_url(img)
                span do
                  link_to image_tag(post_url, size: '150x150', class: 'picture'), post_url
                end
                f.input :img, as: :check_boxes, collection: ["Remove"], input_html: { value: "#{img.id}" }

              elsif img.content_type.include?('video')
                post_url = public_url(img)
                span do
                  video_tag(post_url, controls: true, size: '150x150', class: 'picture')
                end
                f.input :img, as: :check_boxes, collection: ["Remove"], input_html: { value: "#{img.id}" }
              end
            end
          end
        end
      end
      f.input :tags, as: :searchable_select, multiple: true, collection: Crop.all.map { |o| [o.name_en, o.id] }
      f.input :status, input_html: { value: 'admin' }, as: :hidden
    end
    f.semantic_errors
    f.actions
  end

  controller do
    include ApplicationHelper
    after_action :send_notification, only: [:approve_post]
    after_action :send_notification_for_reject, only: [:reject_post]
    def destroy_resource(object)
      object.update(status: 3)
    end

    def create
      @post = Post.new(post_params)
      if @post.valid?
        if post_params[:images].present?
          attachements = []
          post_params[:images].compact_blank.each do |img|
            attachements << MediaService.new.upload_multiple_media(img, 'posts')
          end
          @post.images = attachements
        end
        @post.save
        redirect_to admin_post_path(@post), notice: 'Post Successfully created'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @post = Post.find params[:id]
      @post.assign_attributes(post_params.except(:status,:img,:images))
      if @post.valid?

        new_images_count = post_params[:images].present? ? post_params[:images].compact_blank.count : 0
        remove_images_count = post_params[:img].present? ? post_params[:img].compact_blank.count : 0
        images = @post.images.count + new_images_count - remove_images_count
        @post.errors.add(:images, "Total number file is out of range, you can only upload at a time 5 file") if images > 5
        return render :edit, status: :unprocessable_entity  if images > 5

        ActiveStorage::Attachment.where(id: params[:post][:img]).each { |attach| attach.purge }
        if post_params[:images].compact_blank.present?
          attachements = []
          post_params[:images].compact_blank.each do |img|
            attachements << MediaService.new.upload_multiple_media(img, 'posts')
          end
          @post.images.attach(attachements)
        end
        @post.save
        redirect_to admin_post_path(@post), notice: 'Post Successfully updated'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def show
      @post = Post.find_by(id: params[:id])
      redirect_to admin_posts_path, notice: 'You are not authorized' unless @post.present? && !@post.deleted?
      @comments = Comment.includes(:user, :sub_comments).where('comments.post_id = ? AND comments.is_active = ?', @post, true).order('comments.created_at': :desc)
    end

    private

    def post_params
      params.require(:post).permit(:discription, :status, tags: [], images: [], img: [])
    end

    def send_notification
      block_user_ids = []
      post = Post.find_by(id: params[:id])
      block_user_ids << post.user_id
      block_user_ids << BlockedUser.where(blocked_user_id: post.user_id).pluck(:user_id)
      block_user_ids = block_user_ids.flatten.uniq
      # devise_ids = User.joins(:user_tokens).where("user_tokens.login = true AND users.id != #{post.user_id}").pluck('user_tokens.devise_id')
      devise_ids = User.joins(:user_tokens).where("user_tokens.login = true AND users.id NOT IN (?)", block_user_ids).pluck('user_tokens.devise_id')
      image = post.post_post_type? ? public_url(post.images.first) : ''
      PushNotificationJob.perform_later(devise_ids.uniq, post.discription, image, post.id, user_name(post.user))
      # FcmService.new.push_notification(devise_ids.uniq, post.discription, image, post.id, user_name(post.user))

      devise_ids = post.user.user_tokens.where(login: true).pluck(:devise_id)
      PushNotificationJob.perform_later(devise_ids.uniq, post.discription, image, post.id, t('admin.approv'))
      # FcmService.new.push_notification(devise_ids.uniq, post.discription, image, post.id, 'Admin approved your post')
    end

    def send_notification_for_reject
      post = Post.find_by(id: params[:id])
      image = post.post_post_type? ? public_url(post.images.first) : ''
      devise_ids = post.user.user_tokens.where(login: true).pluck(:devise_id)
      # FcmService.new.push_notification(devise_ids.uniq, post.discription, image, post.id, 'Admin reject your post')
      PushNotificationJob.perform_later(devise_ids.uniq, post.discription, image, post.id, t('admin.reject'))
    end
  end

  index download_links: [nil] do
    column 'Description' do |post|
      post&.discription
    end

    unless params[:scope] == 'admin_post'
      column 'User' do |post|
        post.admin? ? 'Admin' : link_to(user_name(post.user), admin_user_path(post.user))
      end
    end

    column 'Post' do |post|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_post_path(post), class: 'btn btn-primary')
      links << link_to(raw("<i class='fas fa-pen'></i> Edit"), edit_admin_post_path(post), class: 'btn btn-success') unless post.status == 'admin'
      links.join('   ').html_safe
    end

    column 'Action' do |post|
      links = []
      if post.review? || post.rejected?
        links << link_to(raw("<i class='fas fa-check'></i> Approve"), approve_post_admin_post_path(post),
                         method: :post, data: { confirm: 'Are you sure approve post?' }, class: 'edit_link member_link')
      end

      if post.review? || post.approved?
        links << link_to(raw("<i class='fas fa-times'></i> Reject"), reject_post_admin_post_path(post),
                         method: :patch, data: { confirm: 'Are you sure reject post?' }, class: 'delete_link member_link')
      end

      if post.admin?
        links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_post_path(post), class: 'btn btn-success')
        links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_post_path(post),
                         method: :delete,
                         data: { confirm: 'Are you sure delete post?' },
                         class: 'btn btn-danger')
      end
      
      unless post.admin?
        links << link_to(raw("<i class='fas fa-comment'></i> Chat"), "/admin/user/#{post.user.id}/chat", method: :post, class: 'btn btn-success') if post.user.active
      end

      div class: 'table_actions' do
        links.join('   ').html_safe
      end
    end
  end

  show title: proc { |post| post.id } do
    attributes_table do
      row 'Description' do |post|
        post.discription.titleize
      end

      row 'Status' do |post|
        post.status.titleize
      end

      unless post.admin?
        row 'user' do |post|
          link_to user_name(post.user), admin_user_path(post.user)
        end
      end

      row 'Tags' do |post|
        Crop.where(id: post.tags).pluck(:name_en)
      end

      if post.images.attached?
        row 'post' do |m|
          image = m.images.includes(:blob).map { |img| public_url(img) if img.content_type.include?('image') }
          video = m.images.includes(:blob).map { |img| public_url(img) if img.content_type.include?('video') }
          ul do
            image.compact.each do |img|
              span do
                link_to image_tag(img, size: '150x150'), img
              end
            end
            video.compact.each do |img|
              span do
                video_tag(img, controls: true, size: '150x150')
              end
            end
          end
        end
      end
      br
      div do
        h3 'Comment'
        render partial: 'comments', locals: { :post => post, :comment => Comment.new }
      end
    end
    br

    if post.complaints.review.present?
      users = User.where(id: post.complaints.review.pluck(:user_id))
      panel 'Post complaints' do
        span link_to raw("<i class='fas fa-check'></i> Approve"), approve_complaint_admin_complaints_path(post_id: post.id,
                                                                                                          ids: post.complaints.pluck(:id)),
                     method: :patch, data: { confirm: 'Are you sure approve this complaint & delete post?' }, class: 'btn btn-success'

        span link_to raw("<i class='fas fa-times'></i> Reject"), reject_complaint_admin_complaints_path(post_id: post.id,
                                                                                                        ids: post.complaints.pluck(:id)),
                     method: :patch, data: { confirm: 'Are you sure reject this complaint?' }, class: 'btn btn-danger'
        br
        br
        table_for users do
          column 'Name' do |user|
            user_name(user)
          end
          column 'Mobile Number' do |user|
            mobile(user.mobile_no)
          end
          column :village
          column 'Action' do |user|
            link_to raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn btn-primary btn-sm'
          end
        end
      end
    end
    br

    comments = post.comments.joins(:complaints).where('complaints.status = 0').uniq
    if comments.present?
      panel 'Comment complaints' do
        comments.each do |comment|
          hr
          div "Description : #{comment.discription}"
          br
          div do
            span link_to raw("<i class='fas fa-check'></i> Approve"),
                         approve_complaint_admin_complaints_path(comment_id: comment.id, ids: comment.complaints.pluck(:id)),
                         method: :patch, data: { confirm: 'Are you sure approve this complaint & delete comment?' },
                         class: 'btn btn-success'
            span link_to raw("<i class='fas fa-times'></i> Reject"), reject_complaint_admin_complaints_path(comment_id: comment.id,
                                                                                                            ids: comment.complaints.pluck(:id)),
                         method: :patch, data: { confirm: 'Are you sure reject this complaint?' }, class: 'btn btn-danger'
          end
          br
          users = User.where(id: comment.complaints.pluck(:user_id))
          table_for users do
            column 'Name' do |user|
              user_name(user)
            end
            column 'Mobile Number' do |user|
              mobile(user.mobile_no)
            end
            column :village
            column 'Action' do |user|
              link_to raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn btn-primary btn-sm'
            end
          end
          br
        end
      end
    end

    sub_comments_ids = post.comments.joins(sub_comments: :complaints).where('complaints.status = 0').pluck('sub_comments.id').uniq
    comments = SubComment.where(id: sub_comments_ids)
    if comments.present?
      panel 'Sub Comment complaints' do
        comments.each do |comment|
          hr
          div "Description : #{comment.discription}"
          br
          div do
            span link_to raw("<i class='fas fa-check'></i> Approve"),
                         approve_complaint_admin_complaints_path(sub_comment_id: comment.id, ids: comment.complaints.pluck(:id)),
                         method: :patch, data: { confirm: 'Are you sure approve this complaint & delete comment?' },
                         class: 'btn btn-success'
            span link_to raw("<i class='fas fa-times'></i> Reject"), reject_complaint_admin_complaints_path(sub_comment_id: comment.id,
                                                                                                            ids: comment.complaints.pluck(:id)),
                         method: :patch, data: { confirm: 'Are you sure reject this complaint?' }, class: 'btn btn-danger'
          end
          br
          users = User.where(id: comment.complaints.pluck(:user_id))
          table_for users do
            column 'Name' do |user|
              user_name(user)
            end
            column 'Mobile Number' do |user|
              mobile(user.mobile_no)
            end
            column :village
            column 'Action' do |user|
              link_to raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn btn-primary btn-sm'
            end
          end
          br
        end
      end
    end
  end

  member_action :approve_post, method: :post do
    post = Post.find(params[:id])
    post.update(status: 1)
    redirect_to admin_post_path(post), notice: 'post approved successfully' if post.save
  end

  member_action :reject_post, method: :patch do
    post = Post.find(params[:id])
    post.update(status: 2)
    redirect_to admin_post_path(post), notice: 'post rejected successfully' if post.save
  end

  member_action :create_comment, method: :post do
    comment = Comment.new(discription: params["discription"], post_id: params["id"], status: 1)
    redirect_to admin_post_path(params["id"]), notice: 'Comment successfully' if comment.save!
  end

  member_action :delete_comment, method: :delete do
    if params["comment_id"].present?
      comment = Comment.find(params["comment_id"])
      comment.update(is_active: false)
      post = comment.post
      post.update(total_comments: post.total_comments - 1)
    elsif params["subComment_id"].present?
      SubComment.find(params["subComment_id"]).update(is_active: false)
    end
    redirect_to admin_post_path(params["id"]), notice: 'Comment successfully deleted'
  end
end
