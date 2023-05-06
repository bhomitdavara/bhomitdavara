class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  has_many :sub_comments, dependent: :destroy
  has_many :complaints, dependent: :destroy
  validates :discription, presence: true
  before_create :add_total_count
  before_destroy :decrete_total_count
  enum :status, %i[user admin], default: :user
  private

  def add_total_count
    post = self.post
    count = post.total_comments
    post.update(total_comments: count + 1)
  end

  def decrete_total_count
    post = self.post
    count = post.total_comments
    post.update(total_comments: count - 1)
  end
end
