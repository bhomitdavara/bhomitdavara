ActiveAdmin.register Feedback do
  menu priority: 11
  actions :all, except: [:new]
  config.clear_action_items!
  includes :user
  filter :user, collection: -> do
    us = []
    User.joins(:feedbacks).select("users.id, CONCAT(users.first_name, ' ', users.last_name) AS name").uniq.each do |u|
      us << [u.name.titleize, u.id]
    end
  end

  index download_links: [nil] do
    column :description
    column 'User' do |feedback|
      link_to user_name(feedback.user), admin_user_path(feedback.user)
    end
  end
end
