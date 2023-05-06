class ProductSerializer
  include JSONAPI::Serializer

  attribute 'title' do |product, params|
    product[params[:title]]
  end

  attribute 'description' do |product, params|
    product[params[:description]]
  end

  attribute 'other_details' do |product, params|
    product[params[:other_details]]
  end

  attribute 'product_type' do |product, params|
    product.product_type[params[:title]]
  end

  attributes :images_url, :tags
end
