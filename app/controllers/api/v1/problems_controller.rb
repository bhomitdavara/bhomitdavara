module Api
  module V1
    class ProblemsController < Api::V1::ApiController
      before_action :set_attribute, only: %i[index show]

      def index
        return render_404(t('crop.bad_request')) unless params[:crop_id].present?

        problems = Problem.where(active: true, crop_id: params[:crop_id]).order(:priority)
        if problems.present?
          problems = ProblemSerializer.new(problems, { params: { title: @title,
                                                                 description: @description } }).serializable_hash
          render_json(t('problem.index.message'), { problems: problems[:data] })
        else
          render_json(t('problem.index.error'))
        end
      end

      def show
        problem = Problem.find_by(id: params[:id], active: true)
        return render_404(t('problem.index.error')) unless problem.present?

        solutions = SolutionSerializer.new(problem.solutions, params: { title: @title, description: @description,
                                                                        sub_title: @sub_title }).serializable_hash[:data]
        problems = ProblemSerializer.new(problem, params: { title: @title, description: @description }).serializable_hash
        problems[:data][:attributes].merge!(solutions: solutions)
        render_json(t('problem.show.message'), { problem: problems[:data] })
      end

      private

      def set_attribute
        if current_user.gujarati?
          @title = 'title_gu'
          @description = 'description_gu'
          @sub_title = 'sub_title_gu'
        elsif current_user.english?
          @title = 'title_en'
          @description = 'description_en'
          @sub_title = 'sub_title_en'
        elsif current_user.hindi?
          @title = 'title_hi'
          @description = 'description_hi'
          @sub_title = 'sub_title_hi'
        end
      end
    end
  end
end
