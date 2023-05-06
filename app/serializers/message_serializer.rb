class MessageSerializer
  include JSONAPI::Serializer
  attributes :created_at, :attachements_url, :admin
  attribute 'content' do |msg|
    msg.content.present? ? msg.content : ""
  end
end
