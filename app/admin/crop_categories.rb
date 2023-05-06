ActiveAdmin.register CropCategory do
  menu parent: 'Crop', priority: 1
  permit_params :name_gu, :name_en, :name_hi, crops_attributes: %i[id name_en name_gu name_hi image _destroy]
  config.filters = false
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_crop_category_path(crop_category), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_crop_category_path(crop_category),
                     method: :delete,
                     data: { confirm: 'Are you sure delete crop category?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Crop Category"), new_admin_crop_category_path)
  end

  form do |f|
    inputs 'Crop category' do
      f.input :name_gu, label: 'Gujarati Name'
      f.input :name_hi, label: 'Hindi Name'
      f.input :name_en, label: 'English Name'
    end

    f.has_many :crops do |c|
      c.input :name_gu, label: 'Gujarati Name'
      c.input :name_hi, label: 'Hindi Name'
      c.input :name_en, label: 'English Name'
      c.input :image, as: :file
      c.input :_destroy, label: 'Delete', as: :boolean unless c.object.new_record?
    end

    f.semantic_errors
    f.actions
  end

  index download_links: [nil] do
    selectable_column
    column :english_name, 'name_en'
    column :gujarati_name, 'name_gu'
    # column :hindi_name, 'name_hi'
    column 'Action' do |crop_category|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_crop_category_path(crop_category), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_crop_category_path(crop_category), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_crop_category_path(crop_category),
                       method: :delete,
                       data: { confirm: 'Are you sure delete crop category?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |crop_category| crop_category.name_en } do
    attributes_table do
      row 'English Name' do
        crop_category.name_en
      end
      row 'Gujarati Name' do
        crop_category.name_gu
      end
      # row 'Hindi Name' do
      #   crop_category.name_hi
      # end
    end

    panel 'Crops' do
      table_for crop_category.crops do
        column :english_name, 'name_en'
        column :gujarati_name, 'name_gu'
        # column :hindi_name, 'name_hi'
        column 'Action' do |crop|
          link_to raw("<i class='far fa-eye'></i> View"), admin_crop_path(crop), class: 'btn btn btn-primary btn-sm'
        end
      end
    end
  end
end
