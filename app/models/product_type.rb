class ProductType < ApplicationRecord
  include ApplicationHelper
  has_many :products, dependent: :destroy
  has_one_attached :image
  validates :title_en, :title_gu, :title_hi, presence: { message: "Can't be blank" }
  validates :image, presence: { message: 'Please select image' }, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg'],
                                                                                  message: :bad_profile }
  validates :image, attached: true, size: { less_than: 5.megabytes, message: :too_large }

  def image_url
    image.attached? ? public_url(image) : ''
  end
end
