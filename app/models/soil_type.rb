class SoilType < ApplicationRecord
  has_many :users

  validates :name_en, :name_gu, :name_hi, presence: { message: "Can't be blank" }
  before_destroy :update_users

  private

  def update_users
    self.users.update(soil_type_id: '')
  end
end
