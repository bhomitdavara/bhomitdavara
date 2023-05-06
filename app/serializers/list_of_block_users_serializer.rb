class ListOfBlockUsersSerializer
  include JSONAPI::Serializer

  attribute 'users' do |blocked_user|
    user = blocked_user.blocked_user
    {
      id: user.id,
      name: "#{user.first_name} #{user.last_name}",
      profile_url: user.profile_url
    }
  end

end