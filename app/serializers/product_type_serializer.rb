class ProductTypeSerializer
  include JSONAPI::Serializer

  attribute 'title' do |p, params|
    p[params[:title]]
  end

  attributes :image_url
end
