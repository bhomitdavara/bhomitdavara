class Report < ApplicationRecord
  enum :status, %i[review approved rejected], default: :review
  belongs_to :user
  belongs_to :reported_user, class_name:'User', foreign_key: 'reported_user_id'

  validates :description, presence: { message: "Can't be blank" }
  
  scope :active_report, -> { review }
  scope :all_users_history, -> { all }
end
