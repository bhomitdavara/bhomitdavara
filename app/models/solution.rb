class Solution < ApplicationRecord
  belongs_to :problem

  validates :title_en, :title_gu, :title_hi, :sub_title_en, :sub_title_gu, :sub_title_hi, :description_en, :description_gu,
            :description_hi, presence: { message: "Can't be blank" }
end
