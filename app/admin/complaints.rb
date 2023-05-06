ActiveAdmin.register Complaint do
  menu false

  collection_action :approve_complaint, method: :patch do
    complaints = Complaint.where(id: params[:ids])
    complaints.update_all(status: 1)
    if params[:post_id].present?
      Post.find_by(id: params[:post_id]).update(status: 3)
      redirect_to request.env['HTTP_REFERER'], notice: 'Complaint approved & post deleted successfully'
    elsif params[:comment_id].present?
      Comment.find_by(id: params[:comment_id]).update(is_active: false)
      redirect_to request.env['HTTP_REFERER'], notice: 'Complaint approved & comment deleted successfully'
    elsif params[:sub_comment_id].present?
      SubComment.find_by(id: params[:sub_comment_id]).update(is_active: false)
      redirect_to request.env['HTTP_REFERER'], notice: 'Complaint approved & sub comment deleted successfully'
    end
  end

  collection_action :reject_complaint, method: :patch do
    complaints = Complaint.where(id: params[:ids]).includes(:user)
    complaints.update_all(status: 2)
    redirect_to request.env['HTTP_REFERER'], notice: 'Complaint Reject successfully'
  end
end

ActiveAdmin.register_page 'Post Complaint' do
  menu parent: 'Complaints', priority: 1

  content do
    posts = Post.joins(:complaints).where.not(status: 3).includes(:complaints).uniq
    panel 'Post Complaints' do
      if posts.present?
        table_for posts do
          column 'Description' do |post|
            post&.discription
          end

          column 'Total user' do |post|
            user = Complaint.joins(:post).where("post_id = #{post.id}").pluck(:user_id)
            user.count
          end

          column 'Status' do |post|
            status = post.complaints.last.status.titleize
            raw "<span class='#{status}'>#{status}</span>"
          end

          column 'View Post' do |post|
            link_to raw("<i class='far fa-eye'></i> View"), admin_post_path(post), class: 'btn btn btn-primary'
          end

          column 'Action' do |post|
            status = post.complaints.last.status
            links = []
            if status == 'review'
              links << link_to(raw("<i class='fas fa-check'></i> Approve"),
                               approve_complaint_admin_complaints_path(post_id: post.id, ids: post.complaints.pluck(:id)),
                               method: :patch, data: { confirm: 'Are you sure approve this complaint & delete post?' },
                               class: 'btn btn-success')
              links << link_to(raw("<i class='fas fa-times'></i> Reject"),
                               reject_complaint_admin_complaints_path(post_id: post.id, ids: post.complaints.pluck(:id)),
                               method: :patch, data: { confirm: 'Are you sure reject this complaint?' }, class: 'btn btn-danger')
            end
            links.join('   ').html_safe
          end
        end
      else
        'No complaint Post available'
      end
    end
  end
end

ActiveAdmin.register_page 'Comment Complaint' do
  menu parent: 'Complaints', priority: 2

  content do
    comments = Comment.joins(:complaints).where(is_active: true).includes(:complaints, :user).uniq
    panel 'Comment Complaints' do
      if comments.present?
        table_for comments do
          column 'Description' do |comment|
            comment&.discription
          end

          column 'Commented user' do |comment|
            user_name(comment.user)
          end

          column 'Status' do |comment|
            status = comment.complaints.last.status.titleize
            raw "<span class='#{status}'>#{status}</span>"
          end

          column 'Total user' do |comment|
            user = Complaint.joins(:comment).where("comment_id = #{comment.id}").pluck(:user_id)
            user.count
          end

          column 'View complaints' do |comment|
            link_to(raw("<i class='far fa-eye'></i> View"), admin_post_path(comment.post_id), class: 'btn btn-primary')
          end

          column 'Action' do |comment|
            status = comment.complaints.last.status
            links = []
            if status == 'review'
              links << link_to(raw("<i class='fas fa-check'></i> Approve"),
                               approve_complaint_admin_complaints_path(comment_id: comment.id, ids: comment.complaints.pluck(:id)),
                               method: :patch, data: { confirm: 'Are you sure approve this complaint & delete comment?' },
                               class: 'btn btn-success')
              links << link_to(raw("<i class='fas fa-times'></i> Reject"),
                               reject_complaint_admin_complaints_path(comment_id: comment.id, ids: comment.complaints.pluck(:id)),
                               method: :patch, data: { confirm: 'Are you sure reject this complaint?' }, class: 'btn btn-danger')
            end
            links.join('   ').html_safe
          end
        end
      else
        'No complaint Comment available'
      end
    end
  end
end

ActiveAdmin.register_page 'Sub Comment Complaint' do
  menu parent: 'Complaints', priority: 3

  content do
    comments = SubComment.joins(:complaints).where(is_active: true).includes(:complaints, :comment, :user).uniq
    panel 'Sub Comment Complaints' do
      if comments.present?
        table_for comments do
          column 'Description' do |comment|
            comment&.discription
          end

          column 'Commented user' do |comment|
            user_name(comment.user)
          end

          column 'Status' do |comment|
            status = comment.complaints.last.status.titleize
            raw "<span class='#{status}'>#{status}</span>"
          end

          column 'Total user' do |comment|
            user = Complaint.joins(:sub_comment).where("sub_comment_id = #{comment.id}").pluck(:user_id)
            user.count
          end

          column 'View complaints' do |comment|
            link_to raw("<i class='far fa-eye'></i> View"), admin_post_path(comment.post_id), class: 'btn btn-primary'
          end

          column 'Action' do |comment|
            status = comment.complaints.last.status
            links = []
            if status == 'review'
              links << link_to(raw("<i class='fas fa-check'></i> Approve"),
                               approve_complaint_admin_complaints_path(sub_comment_id: comment.id, ids: comment.complaints.pluck(:id)),
                               method: :patch, data: { confirm: 'Are you sure approve this complaint & delete comment?' },
                               class: 'btn btn-success')
              links << link_to(raw("<i class='fas fa-times'></i> Reject"),
                               reject_complaint_admin_complaints_path(sub_comment_id: comment.id, ids: comment.complaints.pluck(:id)),
                               method: :patch, data: { confirm: 'Are you sure reject this complaint?' }, class: 'btn btn-danger')
            end
            links.join('   ').html_safe
          end
        end
      else
        'No complaint Sub Comment available'
      end
    end
  end
end
