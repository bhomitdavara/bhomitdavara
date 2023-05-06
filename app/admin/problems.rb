ActiveAdmin.register Problem do
  menu parent: 'General information'
  permit_params :title_en, :title_gu, :title_hi, :description_en, :description_gu, :description_hi, :crop_id, :active, :priority,
                images: [], tags: [], solutions_attributes: %i[id title_hi sub_title_en sub_title_gu sub_title_hi
                                                               description_en description_gu description_hi _destroy]
  filter :crop, collection: -> { Crop.all.pluck(:name_en, :id) }
  filter :active
  filter :title_en
  filter :title_gu
  includes :crop
  scope :all, default: true
  scope :active
  scope :deactive
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_problem_path(problem), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_problem_path(problem),
                     method: :delete,
                     data: { confirm: 'Are you sure delete problem?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> Add information"), new_admin_problem_path)
  end

  form title: 'General information' do |f|
    inputs 'General information' do
      f.input :crop_id, as: :select, collection: Crop.all.map { |o| [o.name_gu, o.id] }, include_blank: false
      f.input :priority, input_html: { min: '0', id: 'priority' }
      f.input :title_en, label: 'English Title'
      f.input :title_gu, label: 'Gujarati Title'
      f.input :title_hi, label: 'Hindi Title'
      f.input :description_en, label: 'English Description', as: :text
      f.input :description_gu, label: 'Gujarati Description', as: :text
      f.input :description_hi, label: 'Hindi Description', as: :text
      f.input :active, as: :boolean
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :tags, as: :searchable_select, multiple: true, collection: Product.all.map { |o| [o.title_en, o.id] }
    end

    f.has_many :solutions do |c|
      c.input :title_en, label: 'English Title'
      c.input :title_gu, label: 'Gujarati Title'
      c.input :title_hi, label: 'Hindi Title'
      c.input :sub_title_en, label: 'English Sub Title'
      c.input :sub_title_gu, label: 'Gujarati Sub Title'
      c.input :sub_title_hi, label: 'Hindi Sub Title'
      c.input :description_en, label: 'English Description', as: :text
      c.input :description_gu, label: 'Gujarati Description', as: :text
      c.input :description_hi, label: 'Hindi Description', as: :text
      c.input :_destroy, label: 'Delete', as: :boolean unless c.object.new_record?
    end
    f.semantic_errors
    f.actions
  end

  index download_links: [nil], title: 'General information' do
    column :english_title, 'title_en'
    column :gujarati_title, 'title_gu'
    # column :hindi_title, 'title_hi'
    column :priority
    column 'Active' do |problem|
      problem.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
    end
    column 'Crop' do |c|
      link_to c.crop.name_en, admin_crop_path(c.crop)
    end
    column 'Action' do |problem|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_problem_path(problem), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_problem_path(problem), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_problem_path(problem),
                       method: :delete,
                       data: { confirm: 'Are you sure delete problem?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |problem| problem.title_en } do
    panel '' do
      ul do
        problem.images_url.each do |img|
          span do
            link_to image_tag(img, size: '150x150'), img
          end
        end
      end
    end

    attributes_table title: '' do
      row('English Title') { |r| r&.title_en }
      row('Gujarati Title') { |r| r&.title_gu }
      # row('Hindi Title') { |r| r&.title_hi }
      row('English Description') { |r| r&.description_en }
      row('Gujarati Description') { |r| r&.description_gu }
      # row('Hindi Description') { |r| r&.description_hi }
      row 'Active' do |problem|
        problem.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
      end
      row 'crop' do |p|
        p.crop.name_en
      end
      row 'Tags' do |problem|
        Product.where(id: problem.tags).pluck(:title_en)
      end
    end

    panel 'Solutions' do
      table_for problem.solutions do
        column :english_title, 'title_en'
        column :gujarati_title, 'title_gu'
        # column :hindi_title, 'title_hi'
        column 'Action' do |solution|
          link_to raw("<i class='far fa-eye'></i> View"), admin_solution_path(solution), class: 'btn btn-primary'
        end
      end
    end
  end

  controller do
    def create
      @problem = Problem.new(problem_params)
      if @problem.valid?
        if problem_params[:images].compact_blank.present?
          attachements = []
          problem_params[:images].compact_blank.each do |img|
            attachements << MediaService.new.upload_media(img, 'problems')
          end
          @problem.images = attachements
        end
        @problem.save
        redirect_to admin_problem_path(@problem), notice: 'Problem Successfully created'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @problem = Problem.find params[:id]
      problem_params[:images].compact_blank.present? ? @problem.assign_attributes(problem_params) : @problem.assign_attributes(problem_params.except(:images))
      if @problem.valid?
        if problem_params[:images].compact_blank.present?
          attachements = []
          problem_params[:images].compact_blank.each do |img|
            attachements << MediaService.new.upload_media(img, 'problems')
          end
          @problem.images = attachements
        end
        @problem.save
        redirect_to admin_problem_path(@problem), notice: 'Problem Successfully updated'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def problem_params
      params.require(:problem).permit(:title_en, :title_gu, :title_hi, :description_en, :description_gu, :description_hi,
                                      :crop_id, :active, :priority,
                                      images: [], tags: [],
                                      solutions_attributes: %i[id title_en title_gu title_hi sub_title_en sub_title_gu sub_title_hi
                                                               description_en description_gu description_hi _destroy])
    end
  end
end
