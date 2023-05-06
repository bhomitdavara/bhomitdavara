ActiveAdmin.register State do
  menu priority: 3
  permit_params :name_gu, :name_en, :name_hi, districts_attributes: %i[id name_en name_gu name_hi _destroy]
  config.filters = false
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_state_path(state), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_state_path(state), method: :delete,
                                                                                          data: { confirm: 'Are you sure delete state?' },
                                                                                          class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New State"), new_admin_state_path)
  end

  index download_links: [nil] do
    selectable_column
    column :english_name, 'name_en'
    column :gujarati_name, 'name_gu'
    # column :hindi_name, 'name_hi'
    column 'Action' do |state|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_state_path(state), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_state_path(state), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_state_path(state), method: :delete,
                                                                                            data: { confirm: 'Are you sure delete state?' },
                                                                                            class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  form do |f|
    inputs 'State' do
      f.input :name_en, label: 'English Name'
      f.input :name_gu, label: 'Gujarati Name'
      f.input :name_hi, label: 'Hindi Name'
    end

    f.has_many :districts do |c|
      c.input :name_en, label: 'English Name'
      c.input :name_gu, label: 'Gujarati Name'
      c.input :name_hi, label: 'Hindi Name'
      c.input :_destroy, label: 'Delete', as: :boolean unless c.object.new_record?
    end

    f.semantic_errors
    f.actions
  end

  show title: proc { |state| state.name_en } do
    attributes_table do
      row 'English Name' do
        state.name_en
      end
      row 'Gujarati Name' do
        state.name_gu
      end
      # row 'Hindi Name' do
      #   state.name_hi
      # end
    end

    panel 'Districts' do
      table_for state.districts do
        column :english_name, 'name_en'
        column :gujarati_name, 'name_gu'
        # column :hindi_name, 'name_hi'
        column 'Action' do |districts|
          link_to raw("<i class='far fa-eye'></i> View"), admin_district_path(districts), class: 'btn btn-primary'
        end
      end
    end
  end
end
