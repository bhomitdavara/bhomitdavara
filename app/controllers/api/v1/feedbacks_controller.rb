module Api
  module V1
    class FeedbacksController < Api::V1::ApiController
      def create
        feedback = Feedback.new(feedback_params.merge(user: current_user))
        if feedback.save
          feedback = FeedbackSerializer.new(feedback).serializable_hash
          render_json(t('feedback.create.message'), { feedback: feedback[:data] })
        else
          render_422(feedback.errors.messages)
        end
      end

      private

      def feedback_params
        params.require(:feedback).permit(:description)
      end
    end
  end
end
