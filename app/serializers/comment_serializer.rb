class CommentSerializer
  include JSONAPI::Serializer
  attributes :discription, :created_at, :sub_comments

  attribute 'user' do |comment, params|
    user = comment.user
    { id: user.id,
      name: "#{user.first_name} #{user.last_name}",
      profile_url: user.profile_url,
      state: user.state[params[:name]],
      district: user.district[params[:name]],
      village: user.village }
  end
end
