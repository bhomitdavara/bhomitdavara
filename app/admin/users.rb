ActiveAdmin.register User do
  menu priority: 1
  actions :all, except: [:new]
  remove_filter :profile_blob, :profile_attachment, :active, :favourite_crops, :created_at,
                :updated_at, :mobile_no, :otp, :language
  config.clear_action_items!
  filter :state, collection: -> { State.all.pluck(:name_en, :id) }
  filter :district, collection: -> { District.all.pluck(:name_en, :id) }
  filter :soil_type, collection: -> { SoilType.all.pluck(:name_en, :id) }
  filter :village
  includes :soil_type, :district, :state
  scope :active, default: true
  scope :deactive
  scope :blocked

  index download_links: [nil] do
    selectable_column
    column 'Name' do |user|
      user_name(user)
    end

    column 'Mobile Number' do |user|
      mobile(user.mobile_no)
    end

    column 'State' do |user|
      user.state.name_en if user.state.present?
    end

    column 'District' do |user|
      user.district.name_en if user.district.present?
    end

    column :village, :sortable => false
    column 'Soil_type' do |user|
      user.soil_type.name_en if user.soil_type.present?
    end

    column 'Action' do |user|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn-primary')
      links << link_to(raw("<i class='fas fa-comment'></i> Chat"), "/admin/user/#{user.id}/chat",
                       method: :post, class: 'btn btn-success') if user.active
      links << link_to(raw("<i class='fa fa-unlock'></i> Unblock"), unblock_admin_user_path(user),
                       method: :post, class: 'btn btn-success') if user.status == 'block'
      links.join('    ').html_safe
    end
  end

  show title: proc { |user| user_name(user) } do
    panel 'User Profile' do
      user.profile.attached? ? link_to(image_tag(user.profile_url, size: '150x150'), user.profile_url) : ''
    end

    attributes_table title: '' do
      row 'name' do |user|
        user_name(user)
      end

      row 'Mobile Number' do |user|
        mobile(user.mobile_no)
      end

      row 'State' do |user|
        link_to(user.state.name_en, admin_state_path(user.state)) if user.state.present?
      end

      row 'District' do |user|
        link_to(user.district.name_en, admin_district_path(user.district)) if user.district.present?
      end

      row 'Soil type' do |user|
        link_to(user.soil_type.name_en, admin_soil_type_path(user.soil_type)) if user.soil_type.present?
      end

      row :village
      row 'Active' do |product|
        product.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
      end

      row 'Status' do |user|
        user.status.capitalize
      end
    end
    br

    blocked_users = user.blocked_users
    if blocked_users.present?
      panel "Blocked List" do
        users = User.where(id: blocked_users.pluck(:blocked_user_id))
        table_for users do
          column 'Name' do |user|
            user_name(user)
          end
          column 'Mobile Number' do |user|
            mobile(user.mobile_no)
          end
          column 'Village' do |user|
            user.village.capitalize.present? ? user.village.capitalize : 'Null' 
          end
          column 'Action' do |user|
            link_to raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn btn-primary btn-sm'
          end
        end
      end
    end
    br

    blocked_by_users = user.blocked_by
    if blocked_by_users.present?
      panel 'Blocked by' do
        users = User.where(id: blocked_by_users.pluck(:user_id))
        table_for users do
          column 'Name' do |user|
            user_name(user)
          end
          column 'Mobile Number' do |user|
            mobile(user.mobile_no)
          end
          column 'Village' do |user|
            user.village.capitalize
          end
          column 'Action' do |user|
            link_to raw("<i class='far fa-eye'></i> View"), admin_user_path(user), class: 'btn btn btn-primary btn-sm'
          end
        end
      end
    end
  end

  member_action :unblock, method: :post do
    user = User.find(params[:id])
    redirect_to admin_user_path(user), notice: 'Successfully unblock the user' if user.update(status: 'unblock')
  end

end
