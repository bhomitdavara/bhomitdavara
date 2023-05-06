module Api
  module V1
    class ComplaintsController < Api::V1::ApiController
      def create
        complaint = Complaint.find_or_initialize_by(complaint_params.merge(user: current_user))
        if complaint.save
          render_json(t('complaint.create.message'))
        else
          render_422(complaint.errors.messages)
        end
      end

      private

      def complaint_params
        params.require(:complaint).permit(:comment_id, :post_id, :sub_comment_id)
      end
    end
  end
end
