ActiveAdmin.register Crop do
  menu parent: 'Crop', priority: 2

  permit_params :name_gu, :name_en, :name_hi, :crop_category_id, :image

  remove_filter :created_at, :updated_at, :name_en, :name_gu, :name_hi, :image_blob, :image_attachment
  filter :crop_category, collection: -> { CropCategory.all.pluck(:name_en, :id) }
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_crop_path(crop), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_crop_path(crop),
                     method: :delete,
                     data: { confirm: 'Are you sure delete crop?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Crop"), new_admin_crop_path)
  end

  controller do
    def create
      @crop = Crop.new(crop_params)
      if @crop.valid?
        if crop_params[:image].present?
          image = MediaService.new.upload_media(crop_params[:image], 'crops')
          @crop.image.attach(image)
        end
        @crop.save
        redirect_to admin_crop_path(@crop), notice: 'Crop Successfully created'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @crop = Crop.find params[:id]
      @crop.assign_attributes(crop_params)
      if @crop.valid?
        @crop.update(crop_params.except(:image))
        if crop_params[:image].present?
          image = MediaService.new.upload_media(crop_params[:image], 'crops')
          @crop.image.attach(image)
        end
        redirect_to admin_crop_path(@crop), notice: 'Crop Successfully updated'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def crop_params
      params.require(:crop).permit(:name_gu, :name_en, :name_hi, :image, :crop_category_id)
    end
  end

  form do |f|
    inputs 'Crop Categories' do
      f.input :crop_category, as: :select, collection: CropCategory.all.map { |o| [o.name_gu, o.id] }, include_blank: false
      f.input :name_gu, label: 'Gujarati Name'
      f.input :name_hi, label: 'Hindi Name'
      f.input :name_en, label: 'English Name'
      f.input :image, as: :file
    end
    f.semantic_errors
    f.actions
  end

  index download_links: [nil] do
    column :english_name, 'name_en'
    column :gujarati_name, 'name_gu'
    # column :hindi_name, 'name_hi'
    column 'Action' do |crop|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_crop_path(crop), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_crop_path(crop), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_crop_path(crop), method: :delete,
                                                                                          data: { confirm: 'Are you sure delete crop?' },
                                                                                          class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |crop| crop.name_en } do
    panel 'Crop Details' do
      crop.image.attached? ? link_to(image_tag(crop.image_url, size: '150x150'), crop.image_url) : ''
    end

    attributes_table title: '' do
      row 'English Name' do
        crop.name_en
      end
      row 'Gujarati Name' do
        crop.name_gu
      end
      # row 'Hindi Name' do
      #   crop.name_hi
      # end
    end
  end
end
