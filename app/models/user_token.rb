class UserToken < ApplicationRecord
  belongs_to :user
  validates :devise_id, presence: true
end
