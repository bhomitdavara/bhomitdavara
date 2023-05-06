ActiveAdmin.register ProductUniqueness do
  menu parent: 'Products'
  permit_params :title_en, :title_gu, :title_hi, :sub_title_en, :sub_title_gu,
                :sub_title_hi, :description_en, :description_gu, :description_hi, :product_id
  remove_filter :created_at, :updated_at, :title_en, :title_gu, :title_hi, :sub_title_en, :sub_title_gu,
                :sub_title_hi, :description_en, :description_gu, :description_hi
  filter :product, collection: -> { Product.all.pluck(:title_gu, :id) }
  includes :product
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_product_uniqueness_path(product_uniqueness),
                     class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_product_uniqueness_path(product_uniqueness),
                     method: :delete,
                     data: { confirm: 'Are you sure delete product?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Product Uniqueness"), new_admin_product_uniqueness_path)
  end

  form do |f|
    inputs 'Products' do
      f.input :product_id, as: :select, collection: Product.all.map { |o| [o.title_gu, o.id] }, include_blank: false
      f.input :title_en, label: 'English Title'
      f.input :title_gu, label: 'Gujarati Title'
      f.input :title_hi, label: 'Hindi Title'
      f.input :sub_title_en, label: 'English Sub Title'
      f.input :sub_title_gu, label: 'Gujarati Sub Title'
      f.input :sub_title_hi, label: 'Hindi Sub Title'
      f.input :description_en, label: 'English Description', as: :text
      f.input :description_gu, label: 'Gujarati Description', as: :text
      f.input :description_hi, label: 'Hindi Description', as: :text
    end
    f.semantic_errors
    f.actions
  end

  index download_links: [nil] do
    column :english_title, 'title_en'
    column :gujarati_title, 'title_gu'
    # column :hindi_title, 'title_hi'
    column :product do |p|
      link_to p.product.title_gu, admin_products_path
    end
    column 'Action' do |product|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_product_uniqueness_path(product), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_product_uniqueness_path(product), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_product_uniqueness_path(product),
                       method: :delete,
                       data: { confirm: 'Are you sure delete product?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |product| product.title_en } do
    attributes_table do
      row('English Title') { |r| r&.title_en }
      row('Gujarati Title') { |r| r&.title_gu }
      # row('Hindi Title') { |r| r&.title_hi }
      row('English Sub Title') { |r| r&.sub_title_en }
      row('Gujarati Sub Title') { |r| r&.sub_title_gu }
      # row('Hindi Sub Title') { |r| r&.sub_title_hi }
      row('English Description') { |r| r&.description_en }
      row('Gujarati Description') { |r| r&.description_gu }
      # row('Hindi Description') { |r| r&.description_hi }
    end
  end
end
