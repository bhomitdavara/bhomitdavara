class ListingFromPostSerializer
  include JSONAPI::Serializer
  attributes :discription, :post_url_with_measurement, :status, :post_type, :total_comments, :total_likes, :created_at

  attribute 'tags' do |post, params|
    user = params[:current_user]
    if user.gujarati?
      @name = 'name_gu'
    elsif user.english?
      @name = 'name_en'
    elsif user.hindi?
      @name = 'name_hi'
    end
    Crop.where(id: post.tags).pluck(@name)
  end

  attribute 'liked' do |post, params|
    # user = params[:user].present? ? params[:user] : params[:current_user]
    user = params[:current_user]
    post.likes.find_by(user_id: user.id, liked: true).present? ? true : false
  end

  attribute 'user' do |post|
    if post.admin? || (post.deleted? && post.user.nil?)
      {}
    else
      user = post.user
      district = user.district.present? ? user.district[@name] : ''
      state = user.state.present? ? user.state[@name] : ''
      { id: user.id.to_s,
        name: "#{user.first_name} #{user.last_name}",
        profile_url: user.profile_url,
        state: state,
        district: district,
        village: user.village }
    end
  end
end
