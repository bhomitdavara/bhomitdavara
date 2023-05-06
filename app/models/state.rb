class State < ApplicationRecord
  has_many :districts, dependent: :destroy
  has_many :users
  accepts_nested_attributes_for :districts, allow_destroy: true

  validates :name_en, :name_gu, :name_hi, presence: { message: "Can't be blank" }
  before_destroy :update_users

  private

  def update_users
    self.users.update(state_id: '')
  end
end
