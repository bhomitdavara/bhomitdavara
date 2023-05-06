module Api
  module V1
    class FertilizerSchedulesController < Api::V1::ApiController
      before_action :set_attribute, only: %i[index show]

      def index
        return render_400(t('crop.bad_request')) unless params[:crop_id].present?

        fertilizer_schedules = FertilizerSchedule.where(active: true, crop_id: params[:crop_id]).order(:priority)
        if fertilizer_schedules.present?
          fertilizer_schedules = FertilizerScheduleSerializer.new(fertilizer_schedules,
                                                                  { params: { date_duration: @date_duration, note: @note,
                                                                              day_duration: @day_duration, advice: @advice,
                                                                              fertilizer: @fertilizer } }).serializable_hash
          render_json(t('fertilizer.message'), { fertilizer_schedule: fertilizer_schedules[:data] })
        else
          render_json(t('fertilizer.error'))
        end
      end

      private

      def set_attribute
        if current_user.gujarati?
          @date_duration = 'date_duration_gu'
          @day_duration = 'day_duration_gu'
          @note = 'note_gu'
          @fertilizer = 'fertilizer_gu'
          @advice = 'advice_gu'
        elsif current_user.english?
          @date_duration = 'date_duration_en'
          @day_duration = 'day_duration_en'
          @note = 'note_en'
          @fertilizer = 'fertilizer_en'
          @advice = 'advice_en'
        elsif current_user.hindi?
          @date_duration = 'date_duration_hi'
          @day_duration = 'day_duration_hi'
          @note = 'note_hi'
          @fertilizer = 'fertilizer_hi'
          @advice = 'advice_hi'
        end
      end
    end
  end
end
