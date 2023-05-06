ActiveAdmin.register District do
  menu priority: 2
  permit_params :name_gu, :name_en, :name_hi, :state_id
  filter :state, collection: -> { State.all.pluck(:name_en, :id) }
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_district_path(district),
                     class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_district_path(district),
                     method: :delete,
                     data: { confirm: 'Are you sure delete district?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New District"), new_admin_district_path)
  end

  form do |f|
    inputs 'District' do
      f.input :state, as: :select, collection: State.all.map { |o| [o.name_gu, o.id] }, include_blank: false
      f.input :name_gu, label: 'Gujarati Name'
      f.input :name_hi, label: 'Hindi Name'
      f.input :name_en, label: 'English Name'
    end

    f.semantic_errors
    f.actions
  end

  index download_links: [nil] do
    selectable_column
    column :english_name, 'name_en'
    column :gujarati_name, 'name_gu'
    # column :hindi_name, 'name_hi'
    column 'Action' do |district|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_district_path(district), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_district_path(district),
                       class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_district_path(district),
                       method: :delete,
                       data: { confirm: 'Are you sure delete district?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |district| district.name_en } do
    attributes_table do
      row 'English Name' do
        district.name_en
      end
      row 'Gujarati Name' do
        district.name_gu
      end
      # row 'Hindi Name' do
      #   district.name_hi
      # end
    end

    panel 'Users' do
      if district.users.exists?
        table_for district.users do
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
