class UserSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :village, :mobile_no, :profile_url, :active, :language

  attribute 'state' do |user|
    if user.gujarati?
      @name = 'name_gu'
    elsif user.english?
      @name = 'name_en'
    elsif user.hindi?
      @name = 'name_hi'
    end
    user.state_id.present? ? user.state[@name] : ''
  end

  attribute 'favourite_crops' do |user|
    user.favourite_crops.map(&:to_s)
  end

  attribute 'district' do |user|
    user.district_id.present? ? user.district[@name] : ''
  end

  attribute 'soil_type' do |user|
    user.soil_type_id.present? ? user.soil_type[@name] : ''
  end

  attribute 'state_id' do |user|
    user.state_id.present? ? user.state_id.to_s : ''
  end

  attribute 'district_id' do |user|
    user.district_id.present? ? user.district_id.to_s : ''
  end

  attribute 'soil_type_id' do |user|
    user.soil_type_id.present? ? user.soil_type_id.to_s : ''
  end
end
