class SubComment < ApplicationRecord
  belongs_to :comment
  belongs_to :user #, optional: true
  has_many :complaints, dependent: :destroy
  delegate :post_id, to: :comment
  validates :discription, presence: true
  # enum :status, %i[user admin], default: :user
end
