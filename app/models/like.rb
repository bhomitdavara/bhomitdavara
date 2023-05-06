class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user
  before_save :add_total_count

  private

  def add_total_count
    post = self.post
    count = liked ? post.total_likes + 1 : post.total_likes - 1
    post.update(total_likes: count)
  end
end
