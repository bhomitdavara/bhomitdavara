class Product < ApplicationRecord
  include ApplicationHelper
  belongs_to :product_type
  has_many_attached :images
  has_many :product_uniquenesses, dependent: :destroy
  accepts_nested_attributes_for :product_uniquenesses, allow_destroy: true
  before_validation :set_tags
  before_save :set_priority
  before_destroy :decrease_priority

  validates :title_en, :title_gu, :title_hi, :description_en, :description_gu,
            :description_hi, presence: { message: "Can't be blank" }
  validates :priority, comparison: { greater_than_or_equal_to: 0, message: 'Must be greater than or equal to 0' }
  validates :images, presence: { message: 'Please select image' }, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg'],
                                                                                   message: 'Type is invalid. Please select png, jpeg and jpg' }
  # validates_inclusion_of :tags, in: Product.pluck(:id), message: :bad_product_tags
  validates :images, attached: true, size: { less_than: 5.megabytes, message: :too_large }
  scope :active, -> { where(active: true) }
  scope :deactive, -> { where(active: false) }

  def images_url
    images.includes(:blob).map { |img| public_url(img) }
  end

  private

  def set_priority
    return if priority.zero?

    prod_id = id.present? ? id : 0
    products = Product.where("product_type_id = #{product_type_id} AND priority = #{priority} AND id != #{prod_id}")
    return unless products.present?

    if prod_id.zero?
      products = Product.where("product_type_id = #{product_type_id} AND priority >= #{priority} AND id != #{prod_id}")
      products.update_all('priority = priority + 1') if products.present?
    else
      old_priority = Product.find(prod_id).priority
      if old_priority.zero?
        products = Product.where("product_type_id = #{product_type_id} AND priority >= #{priority} AND id != #{prod_id}")
        products.update_all('priority = priority + 1') if products.present?
      elsif old_priority > priority
        products = Product.where("product_type_id = #{product_type_id} AND priority <= #{old_priority} AND priority >= #{priority} AND id != #{prod_id}")
        products.update_all('priority = priority + 1') if products.present?
      else
        products = Product.where("product_type_id = #{product_type_id} AND priority >= #{old_priority} AND priority <= #{priority} AND id != #{prod_id}")
        products.update_all('priority = priority - 1') if products.present?
      end
    end
  end

  def decrease_priority
    return if priority.zero?

    products = Problem.where("product_type_id = #{product_type_id} AND priority > #{priority} AND id != #{id}")
    products.update_all('priority = priority - 1') if products.present?
  end

  def set_tags
    self.tags = tags.compact
  end
end
