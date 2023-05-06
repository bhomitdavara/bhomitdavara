ActiveAdmin.register FertilizerSchedule do
  menu priority: 8
  permit_params :day_duration_en, :day_duration_gu, :day_duration_hi, :date_duration_en, :date_duration_gu, :date_duration_hi,
                :note_en, :note_gu, :note_hi, :active, :crop_id, :priority, fertilizer_items_attributes:
                %i[id fertilizer_en fertilizer_gu fertilizer_hi advice_en advice_gu advice_hi _destroy]

  remove_filter :created_at, :updated_at, :day_duration_en, :day_duration_gu, :day_duration_hi, :date_duration_en,
                :date_duration_gu, :date_duration_hi, :note_en, :note_gu, :note_hi, :active
  filter :crop, collection: -> { Crop.all.pluck(:name_en, :id) }

  scope :all, default: true
  scope :active
  scope :deactive
  includes :crop
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_fertilizer_schedule_path(fertilizer_schedule),
                     class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_fertilizer_schedule_path(fertilizer_schedule),
                     method: :delete,
                     data: { confirm: 'Are you sure delete fertilizer schedule?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Fertilizer Schedule"), new_admin_fertilizer_schedule_path)
  end

  form do |f|
    inputs 'Fertilizer Schedule' do
      f.input :crop_id, as: :select, collection: Crop.all.map { |o| [o.name_gu, o.id] }, include_blank: false
      f.input :priority, input_html: { min: '0', id: 'priority' }
      f.input :day_duration_gu, label: 'Gujarati Day Duration'
      f.input :day_duration_hi, label: 'Hindi Day Duration'
      f.input :day_duration_en, label: 'English Day Duration'
      f.input :date_duration_gu, label: 'Gujarati Date Duration'
      f.input :date_duration_hi, label: 'Hindi Date Duration'
      f.input :date_duration_en, label: 'English Date Duration'
      f.input :note_gu, label: 'Gujarati Note'
      f.input :note_hi, label: 'Hindi Note'
      f.input :note_en, label: 'English Note'
      f.input :active, as: :boolean
    end

    f.has_many :fertilizer_items do |c|
      c.input :fertilizer_gu, label: 'Gujarati Fertilizer'
      c.input :fertilizer_hi, label: 'Hindi Fertilizer'
      c.input :fertilizer_en, label: 'English Fertilizer'
      c.input :advice_gu, label: 'Gujarati Advice'
      c.input :advice_hi, label: 'Hindi Advice'
      c.input :advice_en, label: 'English Advice'
      c.input :_destroy, label: 'Delete', as: :boolean unless c.object.new_record?
    end

    f.semantic_errors
    f.actions
  end

  index download_links: [nil] do
    column :day_duration, 'day_duration_en'
    column :date_duration, 'date_duration_en'
    column :note, 'note_en'
    column 'Crop' do |fertilizer|
      fertilizer.crop.name_en
    end
    column :priority
    column 'Active' do |fertilizer|
      fertilizer.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
    end
    column 'Action' do |fertilizer_schedule|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_fertilizer_schedule_path(fertilizer_schedule),
                       class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_fertilizer_schedule_path(fertilizer_schedule),
                       class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_fertilizer_schedule_path(fertilizer_schedule),
                       method: :delete,
                       data: { confirm: 'Are you sure delete fertilizer schedule?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: '' do |f|
    attributes_table do
      row('English Day Duration') { |r| r&.day_duration_en } if f.day_duration_en.present?
      row('Gujarati Day Duration') { |r| r&.day_duration_gu } if f.day_duration_gu.present?
      row('Hindi Day Duration') { |r| r&.day_duration_hi } if f.day_duration_hi.present?
      row('English Date Duration') { |r| r&.date_duration_en } if f.date_duration_en.present?
      row('Gujarati Date Duration') { |r| r&.date_duration_gu } if f.date_duration_gu.present?
      row('Hindi Date Duration') { |r| r&.date_duration_hi } if f.date_duration_hi.present?
      row('English Note') { |r| r&.note_en } if f.note_en.present?
      row('Gujarati Note') { |r| r&.note_gu } if f.note_gu.present?
      row('Hindi Note') { |r| r&.note_hi } if f.note_hi.present?
      row :priority
      row 'crop' do |fertilizer|
        fertilizer.crop.name_gu
      end
      row 'Active' do |fertilizer|
        fertilizer.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
      end
    end

    panel 'Fertilizer items' do
      table_for fertilizer_schedule.fertilizer_items do
        column :gujarati_fertilizer, 'fertilizer_gu'
        column :english_fertilizer, 'fertilizer_en'
        column :hindi_fertilizer, 'fertilizer_hi'
        column :gujarati_advice, 'advice_gu'
        column :english_advice, 'advice_en'
        column :hindi_advice, 'advice_hi'
      end
    end
  end
end
