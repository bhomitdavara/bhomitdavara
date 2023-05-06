class Post < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :complaints, dependent: :destroy
  before_save :set_type
  before_validation :set_tags
  after_update :update_comment
  after_create :send_notification

  enum :status, %i[review approved rejected deleted admin], default: :review
  enum :post_type, %i[post content], suffix: true
  scope :review, -> { where(status: 'review').includes(:user) }
  scope :approved, -> { where(status: 'approved').includes(:user) }
  scope :rejected, -> { where(status: 'rejected').includes(:user) }
  scope :admin_post, -> { where(status: 'admin') }
  validates :discription, presence: true
  validates :images, limit: { max: 5, message: :max_file }
  validates :images, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg', %r{\Avideo/.*\z}],
                                     message: :bad_post }

  validates_each :images do |record, _attr, _value|
    record.images.each do |attach|
      record.errors.add(:images, :too_large) if attach.content_type.starts_with?('image/') && attach.blob.byte_size > 5_000_000
      record.errors.add(:images, :too_large_v) if attach.content_type.starts_with?('video/') && attach.blob.byte_size > 40_000_000
    end
  end

  def post_url
    video = []
    image = images.map { |img| public_url(img) if img.content_type.include?('image') }
    images.left_joins(blob: :preview_image_attachment).each do |attach|
      if attach.content_type.include?('video')
        height = attach.metadata['height'].present? ? attach.metadata['height'] : 100
        width = attach.metadata['width'].present? ? attach.metadata['width'] : 100
        attach.blob.preview(resize_to_limit: [height, width]).processed unless attach.blob.preview_image.attached?
        video << { thumbnail: public_url(attach.blob.preview_image), url: public_url(attach) }
      end
    end
    { images: image.compact, videos: video }
  end

  def post_url_with_measurement
    video = []
    image_url = []
    images.left_joins(blob: :preview_image_attachment).each do |attach|
      if attach.content_type.include?('video')
        height = attach.metadata['height'].present? ? attach.metadata['height'] : 100
        width = attach.metadata['width'].present? ? attach.metadata['width'] : 100
        attach.blob.preview(resize_to_limit: [height, width]).processed unless attach.blob.preview_image.attached?
        video << { thumbnail: public_url(attach.blob.preview_image), url: public_url(attach), height: height, width: width  }
      elsif attach.content_type.include?('image')
        height = attach.metadata['height'].present? ? attach.metadata['height'] : 100
        width = attach.metadata['width'].present? ? attach.metadata['width'] : 100
        image_url << { url: public_url(attach), height: height, width: width }
      end
    end
    { images: image_url, videos: video }
  end

  private

  def update_comment
    return unless deleted?

    comments.update_all(is_active: false)
    ids = comments.joins(:sub_comments).pluck('sub_comments.id')
    SubComment.where(id: ids).update_all(is_active: false)
  end

  def set_tags
    self.tags = tags.compact
  end

  def set_type
    self.post_type = images.attached? ? 0 : 1
  end

  def send_notification
    # return unless admin?
    if admin?
      devise_ids = User.joins(:user_tokens).where('user_tokens.login = true').pluck('user_tokens.devise_id')
      image = post_post_type? ? public_url(images.first) : ''
      PushNotificationJob.perform_later(devise_ids.uniq, discription, image, id)
      # FcmService.new.push_notification(devise_ids.uniq, discription, image, id)
    else
      devise_ids = user.user_tokens.where('user_tokens.login = true').pluck('user_tokens.devise_id')
      image = post_post_type? ? public_url(images.first) : ''
      PushNotificationJob.perform_later(devise_ids.uniq, discription, image, id, I18n.t('post.create.success'))
    end
  end
end
