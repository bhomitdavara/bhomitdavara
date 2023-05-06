class Problem < ApplicationRecord
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  belongs_to :crop
  has_many_attached :images
  has_many :solutions, dependent: :destroy
  accepts_nested_attributes_for :solutions, allow_destroy: true
  before_validation :set_tags
  before_save :set_priority
  before_destroy :decrease_priority
  validates :title_en, :title_gu, :title_hi, :description_en, :description_gu,
            :description_hi, presence: { message: "Can't be blank" }
  validates :priority, comparison: { greater_than_or_equal_to: 0, message: 'Must be greater than or equal to 0' }
  validates :images, presence: { message: 'Please select image' }, content_type: { in: ['image/png', 'image/jpeg', 'image/jpg'],
                                                                                   message: 'Type is invalid. Please select png, jpeg and jpg' }
  # validates_inclusion_of :tags, in: Product.pluck(:id), message: :bad_problem_tags
  validates :images, attached: true, size: { less_than: 5.megabytes, message: :too_large }
  scope :active, -> { where(active: true) }
  scope :deactive, -> { where(active: false) }

  def images_url
    images.includes(:blob).map { |img| public_url(img) }
  end

  def set_tags
    self.tags = tags.compact
  end

  private

  def set_priority
    return if priority.zero?

    prob_id = id.present? ? id : 0
    problems = Problem.where("crop_id = #{crop_id} AND priority = #{priority} AND id != #{prob_id}")
    return unless problems.present?

    if prob_id.zero?
      problems = Problem.where("crop_id = #{crop_id} AND priority >= #{priority} AND id != #{prob_id}")
      problems.update_all('priority = priority + 1') if problems.present?
    else
      old_priority = Problem.find(prob_id).priority
      if old_priority.zero?
        problems = Problem.where("crop_id = #{crop_id} AND priority >= #{priority} AND id != #{prob_id}")
        problems.update_all('priority = priority + 1') if problems.present?
      elsif old_priority > priority
        problems = Problem.where("crop_id = #{crop_id} AND priority <= #{old_priority} AND priority >= #{priority} AND id != #{prob_id}")
        problems.update_all('priority = priority + 1') if problems.present?
      else
        problems = Problem.where("crop_id = #{crop_id} AND priority >= #{old_priority} AND priority <= #{priority} AND id != #{prob_id}")
        problems.update_all('priority = priority - 1') if problems.present?
      end
    end
  end

  def decrease_priority
    return if priority.zero?

    problems = Problem.where("crop_id = #{crop_id} AND priority > #{priority} AND id != #{id}")
    problems.update_all('priority = priority - 1') if problems.present?
  end
end
