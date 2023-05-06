namespace :attachament do
  require 'open-uri'
  task update_post: :environment do
    Post.post_post_type.each do |post|
      p "post id------------------------------------------->#{post.id}"
      p post.images.count
      post.images.each do |img|
        next if img.blob.service_name == 'amazon'

        di = URI.open(img.url)
        filename = img.blob.filename
        img.purge
        p '--------------------------------------------------------> deleted'
        post.images.attach(io: di, filename: filename)
        p '--------------------------------------------------------> added'
      end
    end
  end

  task update_crop: :environment do
    Crop.all.each do |crop|
      next unless crop.image.attached? && crop.image.blob.service_name != 'amazon'

      p "crop id------------------------------------------->#{crop.id}"
      di = URI.open(crop.image.url)
      filename = crop.image.blob.filename
      crop.image.purge
      crop.image.attach(io: di, filename: filename)
    end
  end

  task update_product: :environment do
    Product.all.each do |product|
      next unless product.image.attached? && product.image.blob.service_name != 'amazon'

      p "product id------------------------------------------->#{product.id}"
      di = URI.open(product.image.url)
      filename = product.image.blob.filename
      product.image.purge
      product.image.attach(io: di, filename: filename)
    end
  end

  task update_problem: :environment do
    Problem.all.each do |problem|
      next unless problem.image.attached? && problem.image.blob.service_name != 'amazon'

      p "problem id------------------------------------------->#{problem.id}"
      di = URI.open(problem.image.url)
      filename = problem.image.blob.filename
      problem.image.purge
      problem.image.attach(io: di, filename: filename)
    end
  end

  task update_product_type: :environment do
    ProductType.all.each do |p_type|
      next unless p_type.image.attached? && p_type.image.blob.service_name != 'amazon'

      p "p_type id------------------------------------------->#{p_type.id}"
      di = URI.open(p_type.image.url)
      filename = p_type.image.blob.filename
      p_type.image.purge
      p_type.image.attach(io: di, filename: filename)
    end
  end

  task update_user: :environment do
    User.all.each do |user|
      next unless user.profile.attached? && user.profile.blob.service_name != 'amazon'

      p "user id------------------------------------------->#{user.id}"
      di = URI.open(user.profile.url)
      filename = user.profile.blob.filename
      user.profile.purge
      user.profile.attach(io: di, filename: filename)
    end
  end
end
