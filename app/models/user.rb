class User < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  belongs_to :state, optional: true
  belongs_to :district, optional: true
  belongs_to :soil_type, optional: true
  has_one_attached :profile
  has_many :posts, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :complaints, dependent: :destroy
  has_many :blocked_users, foreign_key: :user_id, dependent: :destroy
  has_many :blocked_by, class_name:'BlockedUser', foreign_key: :blocked_user_id, dependent: :destroy
  has_many :reports, foreign_key: :user_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :conversation
  has_many :messages, as: :sender
  has_many :user_tokens, dependent: :destroy
  has_many :notifications, dependent: :destroy, as: :recipient

  enum :language, %i[gujarati english hindi], default: :gujarati
  enum :status, %i[unblock block], default: :unblock
  validates :mobile_no, presence: true, format: { with: /\A(\+91[\-\s]?)?0?(91)?[6789]\d{9}\z/ }
  validates :profile, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg'],
                                      message: :bad_profile }
  validates :profile, size: { less_than: 5.megabytes, message: :too_large }
  # validates_inclusion_of :favourite_crops, in: Crop.pluck(:id), message: :bad_tags

  scope :active, -> { where(active: true, status: 'unblock') }
  scope :deactive, -> { where(active: false) }
  scope :blocked, -> { where(status: 'block') }

  def profile_url
    profile.attached? ? public_url(profile) : ''
  end

  def email
    "#{first_name.titleize} #{last_name.titleize}"
  end

  def valid_otp?(otp)
    self.otp == otp
  end
end
