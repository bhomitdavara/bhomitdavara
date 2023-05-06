ActiveAdmin.register SubComment do
  menu false
  controller do
    def create
      post = Comment.find_by_id(params[:comment_id])&.post&.id
      return redirect_to admin_post_path(post), alert: "Description cann't blank" if params[:discription].blank?
      sub_comment = SubComment.new(discription: params[:discription], comment_id: params[:comment_id], is_active: true, status: "admin")
      redirect_to admin_post_path(post), notice: 'Comment successfully' if sub_comment.save
    end
  end
end
