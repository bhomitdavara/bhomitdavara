class Crop < ApplicationRecord
  include ApplicationHelper
  belongs_to :crop_category
  has_one_attached :image, dependent: :destroy
  has_many :problems, dependent: :destroy
  has_many :fertilizer_schedules, dependent: :destroy

  validates :name_en, :name_gu, :name_hi, presence: { message: "Can't be blank" }
  validates :image, presence: { message: 'Please select image' }, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg'],
                                                                                  message: :bad_profile }
  validates :image, attached: true, size: { less_than: 5.megabytes, message: :too_large }

  def image_url
    image.attached? ? public_url(image) : ''
  end
end
