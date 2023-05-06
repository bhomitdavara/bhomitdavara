ActiveAdmin.register Product do
  menu parent: 'Products', priority: 2
  permit_params :product_type_id, :title_en, :title_gu, :title_hi, :other_details_en, :other_details_gu, :other_details_hi,
                :description_en, :description_gu, :description_hi, :active, :priority,
                images: [], tags: [], product_uniquenesses_attributes: %i[id title_en title_gu title_hi sub_title_en sub_title_gu sub_title_hi
                                                                          description_en description_gu description_hi _destroy]

  remove_filter :created_at, :updated_at, :title_hi, :other_details_en, :other_details_gu,
                :other_details_hi, :description_en, :description_gu, :description_hi, :active, :image,
                :tags, :image_blob, :image_attachment, :product_uniquenesses

  filter :product_type, collection: -> { ProductType.all.pluck(:title_en, :id) }
  filter :title_en
  filter :title_gu
  # filter :product_type, as: :select, collection: [['seeds', 0], ['nutrition', 1], ['defense', 2],
  #                                                 ['hardware', 3], ['combo_kit', 4]]
  includes :product_type
  scope :all, default: true
  scope :active
  scope :deactive
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_product_path(product), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_product_path(product),
                     method: :delete,
                     data: { confirm: 'Are you sure delete product?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Product"), new_admin_product_path)
  end

  controller do
    def create
      @product = Product.new(product_params)
      if @product.valid?
        if product_params[:images].compact_blank.present?
          attachements = []
          product_params[:images].compact_blank.each do |img|
            attachements << MediaService.new.upload_media(img, 'products')
          end
          @product.images = attachements
        end
        @product.save
        redirect_to admin_product_path(@product), notice: 'Product Successfully created'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @product = Product.find params[:id]
      product_params[:images].compact_blank.present? ? @product.assign_attributes(product_params) : @product.assign_attributes(product_params.except(:images))
      if @product.valid?
        # @product.update(product_params.except(:images))
        if product_params[:images].compact_blank.present?
          attachements = []
          product_params[:images].compact_blank.each do |img|
           attachements << MediaService.new.upload_media(img, 'products')
          end
          @product.images = attachements
        end
        @product.save
        redirect_to admin_product_path(@product), notice: 'Product Successfully updated'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def product_params
      params.require(:product).permit(:product_type_id, :title_en, :title_gu, :title_hi, :other_details_en, :other_details_gu,
                                      :other_details_hi, :description_en, :description_gu, :description_hi, :active, :priority,
                                      images: [], tags: [],
                                      product_uniquenesses_attributes: %i[id title_en title_gu title_hi sub_title_en sub_title_gu
                                                                          sub_title_hi description_en description_gu description_hi _destroy])
    end
  end

  form do |f|
    inputs 'Products' do
      f.input :product_type_id, as: :select, collection: ProductType.all.map { |o| [o.title_gu, o.id] }, include_blank: false
      f.input :priority, input_html: { min: '0', id: 'priority' }
      # f.input :product_type, as: :select, collection: %w[seeds nutrition defense hardware combo_kit], include_blank: false
      f.input :title_en, label: 'English Title'
      f.input :title_gu, label: 'Gujarati Title'
      f.input :title_hi, label: 'Hindi Title'
      f.input :description_en, label: 'English Description', as: :text
      f.input :description_gu, label: 'Gujarati Description', as: :text
      f.input :description_hi, label: 'Hindi Description', as: :text
      f.input :other_details_en, label: 'English Other details', as: :text
      f.input :other_details_gu, label: 'Gujarati Other details', as: :text
      f.input :other_details_hi, label: 'Hindi Other details', as: :text
      f.input :active, as: :boolean
      products = f.object.new_record? ? Product.where(active: true) : Product.where("active = true AND id != #{f.object.id}")
      f.input :tags, as: :searchable_select, multiple: true, collection: products.map { |o| [o.title_en, o.id] }

      f.input :images, as: :file, input_html: { multiple: true }
    end

    f.has_many :product_uniquenesses do |c|
      c.input :title_en, label: 'English Title'
      c.input :title_gu, label: 'Gujarati Title'
      c.input :title_hi, label: 'Hindi Title'
      c.input :sub_title_en, label: 'English Sub Title'
      c.input :sub_title_gu, label: 'Gujarati Sub Title'
      c.input :sub_title_hi, label: 'Hindi Sub Title'
      c.input :description_en, label: 'English Description', as: :text
      c.input :description_gu, label: 'Gujarati Description', as: :text
      c.input :description_hi, label: 'Hindi Description', as: :text
      c.input :_destroy, label: 'Delete', as: :boolean unless c.object.new_record?
    end

    f.semantic_errors
    f.actions
  end

  index download_links: [nil] do
    column :english_title, 'title_en'
    column :gujarati_title, 'title_gu'
    # column :hindi_title, 'title_hi'
    column :priority
    column 'Active' do |product|
      product.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
    end
    column 'Product Type' do |product|
      product.product_type.title_en
    end
    column 'Action' do |product|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_product_path(product), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_product_path(product), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_product_path(product),
                       method: :delete,
                       data: { confirm: 'Are you sure delete product?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |product| product.title_en } do
    panel 'Product Details' do
      ul do
        product.images_url.each do |img|
          span do
            link_to image_tag(img, size: '150x150'), img
          end
        end
      end
    end

    attributes_table title: '' do
      row('English Title') { |r| r&.title_en }
      row('Gujarati Title') { |r| r&.title_gu }
      # row('Hindi Title') { |r| r&.title_hi }
      row('English Description') { |r| r&.description_en }
      row('Gujarati Description') { |r| r&.description_gu }
      # row('Hindi Description') { |r| r&.description_hi }
      row('English Other Details') { |r| r&.other_details_en }
      row('Gujarati Other Details') { |r| r&.other_details_gu }
      # row('Hindi Other Details') { |r| r&.other_details_hi }
      row 'Product Type' do
        link_to product.product_type.title_en, admin_product_type_path(product.product_type)
      end
      row 'Active' do |product|
        product.active ? raw('<i class="fas fa-check active"></i>') : raw('<i class="fas fa-times reject"></i>')
      end
      row :priority
      row 'Tags' do |product|
        Product.where(id: product.tags).pluck(:title_en)
      end

      panel 'Product Uniqueness' do
        table_for product.product_uniquenesses do
          column :title_en
          column :title_gu
          column :title_hi
          column 'Action' do |uniqueness|
            link_to raw("<i class='far fa-eye'></i> View"), admin_product_uniqueness_path(uniqueness), class: 'btn btn-primary'
          end
        end
      end
    end
  end
end
