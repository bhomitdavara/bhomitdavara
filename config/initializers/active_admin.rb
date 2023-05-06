ActiveAdmin.setup do |config|
  # config.site_title = 'Khedutmall'
  config.site_title_link = '/admin'
  config.site_title_image = 'logo.svg'
  # config.favicon = 'Peanuts.png'

  config.use_webpacker = true
  config.authentication_method = :authenticate_admin_user!

  # ActiveAdmin.setup do |config|
  #   config.namespace :admin do |admin|
  #     admin.build_menu :utility_navigation do |menu|
  #       admin.add_current_user_to_menu  menu
  #       # menu.add label: 'Logout', url: "#", url: "http://www.activeadmin.info",
  #       #                                     html_options: { target: :blank }
  #       admin.add_logout_button_to_menu menu
  #     end
  #   end
  # end

  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path
  config.root_to = 'users#index'
  config.comments = false

  config.filter_attributes = %i[encrypted_password password password_confirmation]

  config.localize_format = :long

  config.namespace :admin do |admin|
    admin.build_menu do |menu|
      menu.add label: 'General information', priority: 9
      menu.add label: 'Products', priority: 7
      menu.add label: 'Crop', priority: 5
      menu.add label: 'Complaints', priority: 10
    end
  end

  config.footer = "Powered by Tagline Infotech #{Date.today.year}"
  config.default_per_page = 50

  meta_tags_options = { viewport: 'width=device-width, initial-scale=1' }
  config.meta_tags = meta_tags_options
  config.meta_tags_for_logged_out_pages = meta_tags_options
end

module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document
        alias original_build_head build_active_admin_head

        def build_active_admin_head
          original_build_head

          within head do
            text_node Gon::Base.render_data({})
          end
        end
      end
    end
  end
end
