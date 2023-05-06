class FertilizerSchedule < ApplicationRecord
  belongs_to :crop
  has_many :fertilizer_items, dependent: :destroy
  accepts_nested_attributes_for :fertilizer_items, allow_destroy: true
  before_save :set_priority
  before_destroy :decrease_priority

  validate :duration
  validates :priority, comparison: { greater_than_or_equal_to: 0, message: 'Must be greater than or equal to 0' }
  scope :active, -> { where(active: true) }
  scope :deactive, -> { where(active: false) }

  private

  def duration
    unless day_duration_en.present? || date_duration_en.present?
      errors.add(:day_duration_en, "Day duration and Date duration both can't be blank")
    end

    unless day_duration_gu.present? || date_duration_gu.present?
      errors.add(:day_duration_gu, "Day duration and Date duration both can't be blank")
    end

    return if day_duration_hi.present? || date_duration_hi.present?

    errors.add(:day_duration_hi, "Day duration and Date duration both can't be blank")
  end

  def set_priority
    return if priority.zero?

    fer_id = id.present? ? id : 0
    fertilizers = FertilizerSchedule.where("crop_id = #{crop_id} AND priority = #{priority} AND id != #{fer_id}")
    return unless fertilizers.present?

    if fer_id.zero?
      fertilizers = FertilizerSchedule.where("crop_id = #{crop_id} AND priority >= #{priority} AND id != #{fer_id}")
      fertilizers.update_all('priority = priority + 1') if fertilizers.present?
    else
      old_priority = FertilizerSchedule.find(fer_id).priority
      if old_priority.zero?
        fertilizers = FertilizerSchedule.where("crop_id = #{crop_id} AND priority >= #{priority} AND id != #{fer_id}")
        fertilizers.update_all('priority = priority + 1') if fertilizers.present?
      elsif old_priority > priority
        fertilizers = FertilizerSchedule.where("crop_id = #{crop_id} AND priority <= #{old_priority} AND priority >= #{priority} AND id != #{fer_id}")
        fertilizers.update_all('priority = priority + 1') if fertilizers.present?
      else
        fertilizers = FertilizerSchedule.where("crop_id = #{crop_id} AND priority >= #{old_priority} AND priority <= #{priority} AND id != #{fer_id}")
        fertilizers.update_all('priority = priority - 1') if fertilizers.present?
      end
    end
  end

  def decrease_priority
    return if priority.zero?

    fertilizers = FertilizerSchedule.where("crop_id = #{crop_id} AND priority > #{priority} AND id != #{id}")
    fertilizers.update_all('priority = priority - 1') if fertilizers.present?
  end
end
