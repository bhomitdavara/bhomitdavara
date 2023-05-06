ActiveAdmin.register About do
  menu false
  actions :update, :edit, :index
  permit_params :text
  config.clear_action_items!

  controller do
    def update
      update!do |format| 
        format.html { redirect_to admin_information_for_user_path}
      end
    end
  end

  form title: false do |f|
    inputs 'About' do
      f.input :text, as: :quill_editor,
                     input_html: { data: { options: { modules: { toolbar: [ ['bold', 'italic', 'underline', 'strike'],
                                                                            ['link', 'blockquote', 'code-block'],
                                                                            [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
                                                                            [{ 'color': [] }, { 'background': [] }],
                                                                            [{ 'font': [] }],
                                                                            [{ 'script': 'sub'}, { 'script': 'super' }],
                                                                            ] }, theme: 'snow' } } }
    end
    f.semantic_errors
    f.actions do
      f.action :submit
      f.cancel_link(admin_information_for_user_path)
    end
  end
end

ActiveAdmin.register Policy do
  menu false
  actions :update, :edit, :index
  permit_params :text
  config.clear_action_items!

  controller do
    def update
      update!do |format| 
        format.html { redirect_to admin_information_for_user_path	}
      end
    end
  end

  form title: 'Edit Policy' do |f|
    inputs 'Privacy Policy' do
      f.input :text, as: :quill_editor,
                     input_html: { data: { options: { modules: { toolbar: [ ['bold', 'italic', 'underline', 'strike'],
                                                                            ['link', 'blockquote', 'code-block'],
                                                                            [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
                                                                            [{ 'color': [] }, { 'background': [] }],
                                                                            [{ 'font': [] }],
                                                                            [{ 'script': 'sub'}, { 'script': 'super' }],
                                                                            ] }, theme: 'snow' } } }
    end
    f.semantic_errors
    f.actions do
      f.action :submit
      f.cancel_link(admin_information_for_user_path	)
    end
  end
end

ActiveAdmin.register_page 'Information for user' do
  content do
    panel 'About App' do
      # div About.first.text.html_safe
      br
      div do
        span link_to "Edit About App", edit_admin_about_path(About.first), class: 'btn btn-success'
        span link_to "View About App Page", about_app_path, class: 'btn btn-primary'
      end
    end

    br hr
    panel 'Privacy Policy' do
      # div Policy.first.text.html_safe
      br
      div do
        span link_to "Edit Privacy Policy", edit_admin_policy_path(Policy.first), class: 'btn btn-success'
        span link_to "View Privacy Policy Page", privacy_policy_path, class: 'btn btn-primary'
      end
    end
  end
end
