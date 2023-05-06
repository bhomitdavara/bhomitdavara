class PostCreateJob < ApplicationJob
  queue_as :default

  def perform(post_params, images, user)
    attachements = []
    if images.present?
      user_name = "#{user.first_name}_#{user.last_name}"
      images.each do |img|
        attachements << MediaService.new.upload_media_via_api(img, 'posts', user_name)
      end
    end
    Post.create(post_params.merge(images: attachements, user: user))
  end
end
