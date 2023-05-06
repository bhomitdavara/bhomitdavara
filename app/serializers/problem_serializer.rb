class ProblemSerializer
  include JSONAPI::Serializer
  attribute 'title' do |product, params|
    product[params[:title]]
  end

  attribute 'description' do |product, params|
    product[params[:description]]
  end

  attributes :images_url, :tags
end
