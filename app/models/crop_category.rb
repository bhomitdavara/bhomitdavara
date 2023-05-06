class CropCategory < ApplicationRecord
  has_many :crops, dependent: :destroy
  accepts_nested_attributes_for :crops, allow_destroy: true

  validates :name_en, :name_gu, :name_hi, presence: { message: "Can't be blank" }
end
