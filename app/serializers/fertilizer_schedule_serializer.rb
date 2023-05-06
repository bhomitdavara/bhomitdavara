class FertilizerScheduleSerializer
  include JSONAPI::Serializer

  attribute 'day_duration' do |fertilizer_schedule, params|
    fertilizer_schedule[params[:day_duration]]
  end

  attribute 'date_duration' do |fertilizer_schedule, params|
    fertilizer_schedule[params[:date_duration]]
  end

  attribute 'note' do |fertilizer_schedule, params|
    fertilizer_schedule[params[:note]]
  end

  attribute 'fertilize_items' do |fertilizer_schedule, params|
    fertilizer_schedule&.fertilizer_items&.select("id, #{params[:fertilizer]} AS fertilizer, #{params[:advice]} AS advice")
  end
end
