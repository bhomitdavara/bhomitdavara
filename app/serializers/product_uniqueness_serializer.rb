class ProductUniquenessSerializer
  include JSONAPI::Serializer
  attribute 'title' do |product, params|
    product[params[:title]]
  end

  attribute 'description' do |product, params|
    product[params[:description]]
  end

  attribute 'sub_title' do |product, params|
    product[params[:sub_title]]
  end
end
