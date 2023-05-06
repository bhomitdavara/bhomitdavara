ActiveAdmin.register Maintenance do
  permit_params :status, :message, :devise_tokens, allowed_users: []
  config.clear_action_items!
  config.filters = false

  index download_links: [nil] do
    column 'Devise Tokens' do |maintenance|
      maintenance.devise_tokens
    end
    column :status, 'status', :sortable => false
    column :message, 'message', :sortable => false
    column 'Allowed Users' do |maintenance|
      maintenance.allowed_users.compact
    end
    column 'Action' do |maintenance|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_maintenance_path(maintenance), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_maintenance_path(maintenance), class: 'btn btn-success') if maintenance.status
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_maintenance_path(maintenance),
                       method: :delete,
                       data: { confirm: 'Are you sure delete maintenance?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |maintenance| maintenance.message } do
    attributes_table do
      row 'Devise Token' do
        maintenance.devise_tokens
      end
      row :status, 'status'
      row :message, 'message'
      row 'Allowed Users' do |maintenance|
        maintenance.allowed_users.compact
      end
    end
   
  end

  action_item :view, only: :index do 
    link_to raw('<i class="fas fa-plus"></i> New Maintenance'), new_admin_maintenance_path, class: 'btn btn-success' 
  end


  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_maintenance_path(maintenance), class: 'btn btn-success') if maintenance.status
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_maintenance_path(maintenance),
                        method: :delete,
                        data: { confirm: 'Are you sure delete maintenance?' },
                        class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  form do |f|
    inputs 'Maintenance' do
      f.input :devise_tokens
      f.input :status, label: 'Status'
      f.input :message, label: 'Message'
      f.input :allowed_users, as: :searchable_select, multiple: true, collection: User.all.map { |o| ["#{o.first_name.titleize} #{o.last_name.titleize}", o.id] }
    end
    f.semantic_errors
    f.actions
  end
end
