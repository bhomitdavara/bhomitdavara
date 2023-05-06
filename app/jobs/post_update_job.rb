class PostUpdateJob < ApplicationJob
  queue_as :default
  include ApplicationHelper

  def perform(post, post_params, images, remove)
    attachements = []
    if images.present?
      user_name = "#{post.user.first_name}_#{post.user.last_name}"
      images.each do |img|
        attachements << MediaService.new.upload_media_via_api(img, 'posts', user_name)
      end
    end
    if remove.present?
      remove.each do |url|
        blob = ActiveStorage::Blob.find_by(key: url[/[^\?]+/].split('.com/'))
        blob.attachments.first.purge if blob.present?
      end
    end
    post.images.attach(attachements)
    post.update(post_params)
    devise_ids = post.user.user_tokens.where('user_tokens.login = true').pluck('user_tokens.devise_id')
    image = post.post_post_type? ? public_url(post.images.first) : ''
    PushNotificationJob.perform_later(devise_ids.uniq, post.discription, image, post.id, I18n.t('post.update.success'))
  end
end
