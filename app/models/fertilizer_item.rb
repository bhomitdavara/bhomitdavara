class FertilizerItem < ApplicationRecord
  belongs_to :fertilizer_schedule

  validates :fertilizer_en, :fertilizer_gu, :fertilizer_hi, :advice_en, :advice_gu,
            :advice_hi, presence: { message: "Can't be blank" }
end
