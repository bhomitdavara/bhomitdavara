class Complaint < ApplicationRecord
  belongs_to :post, optional: true
  belongs_to :comment, optional: true
  belongs_to :sub_comment, optional: true
  belongs_to :user

  enum :status, %i[review approved rejected], default: :review
  validate :post_comment

  private

  def post_comment
    if post_id.present?
      post = Post.find_by(id: post_id)
      errors.add(:post_id, :invalid) unless post.present? && post.approved?
    elsif comment_id.present?
      comment = Comment.find_by(id: comment_id, is_active: true)
      errors.add(:comment_id, :invalid) unless comment.present?
    elsif sub_comment_id.present?
      sub_comment = SubComment.find_by(id: sub_comment_id, is_active: true)
      errors.add(:sub_comment_id, :invalid) unless sub_comment.present?
    else
      errors.add(:post_id, :all_blank)
    end
  end
end
