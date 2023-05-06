ActiveAdmin.register SoilType do
  menu priority: 4
  permit_params :name_gu, :name_en, :name_hi
  config.filters = false
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_soil_type_path(soil_type), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_soil_type_path(soil_type),
                     method: :delete,
                     data: { confirm: 'Are you sure delete soil_type?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Soil Type"), new_admin_soil_type_path)
  end

  index download_links: [nil] do
    column :english_name, 'name_en'
    column :gujarati_name, 'name_gu'
    # column :hindi_name, 'name_hi'
    column 'Action' do |soil_type|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_soil_type_path(soil_type), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_soil_type_path(soil_type), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_soil_type_path(soil_type),
                       method: :delete,
                       data: { confirm: 'Are you sure delete soil_type?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  form do |f|
    inputs 'Soil Type' do
      f.input :name_gu, label: 'Gujarati Name'
      f.input :name_hi, label: 'Hindi Name'
      f.input :name_en, label: 'English Name'
    end

    f.semantic_errors
    f.actions
  end

  show title: proc { |soil_type| soil_type.name_en } do
    attributes_table do
      row 'English Name' do
        soil_type.name_en
      end
      row 'Gujarati Name' do
        soil_type.name_gu
      end
      # row 'Hindi Name' do
      #   soil_type.name_hi
      # end
    end

    panel 'Users' do
      if soil_type.users.exists?
        table_for soil_type.users do
          column 'Name' do |user|
            user_name(user)
          end

          column 'Mobile Number' do |user|
            mobile(user.mobile_no)
          end

          column 'Action' do |user|
            link_to raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn-primary'
          end
        end
      else
        'User Not Found'
      end
    end
  end
end
