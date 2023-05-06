ActiveAdmin.register ProductType do
  menu parent: 'Products', priority: 1
  permit_params :title_en, :title_gu, :title_hi, :image
  config.filters = false
  config.clear_action_items!

  action_item :view, only: :show do
    links = []
    links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_product_type_path(product_type), class: 'btn btn-success')
    links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_product_type_path(product_type),
                     method: :delete,
                     data: { confirm: 'Are you sure delete product type?' },
                     class: 'btn btn-danger')
    links.join('   ').html_safe
  end

  action_item :view, only: :index do
    link_to(raw("<i class='fas fa-plus'></i> New Product Type"), new_admin_product_type_path)
  end

  controller do
    def create
      @product_type = ProductType.new(product_type_params)
      if @product_type.valid?
        if product_type_params[:image].present?
          image = MediaService.new.upload_media(product_type_params[:image], 'product_types')
          @product_type.image.attach(image)
        end
        @product_type.save
        redirect_to admin_product_type_path(@product_type), notice: 'Product Type Successfully created'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @product_type = ProductType.find params[:id]
      @product_type.assign_attributes(product_type_params)
      if @product_type.valid?
        @product_type.update(product_type_params.except(:image))
        if product_type_params[:image].present?
          image = MediaService.new.upload_media(product_type_params[:image], 'product_types')
          @product_type.image.attach(image)
        end
        redirect_to admin_product_type_path(@product_type), notice: 'Product type Successfully updated'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def product_type_params
      params.require(:product_type).permit(:title_en, :title_gu, :title_hi, :image)
    end
  end

  index download_links: [nil] do
    column :english_title, 'title_en'
    column :gujarati_title, 'title_gu'
    # column :hindi_title, 'title_hi'
    column 'Action' do |product_type|
      links = []
      links << link_to(raw("<i class='far fa-eye'></i> View"), admin_product_type_path(product_type), class: 'btn btn-primary')
      links << link_to(raw('<i class="fas fa-pen"></i> Edit'), edit_admin_product_type_path(product_type), class: 'btn btn-success')
      links << link_to(raw("<i class='fas fa-trash'></i> Delete"), admin_product_type_path(product_type),
                       method: :delete,
                       data: { confirm: 'Are you sure delete product type?' },
                       class: 'btn btn-danger')
      links.join('   ').html_safe
    end
  end

  show title: proc { |product_type| product_type.title_en } do
    panel 'Product Type Details' do
      link_to image_tag(product_type.image_url, size: '150x150'), product_type.image_url if product_type.image.attached?
    end

    attributes_table title: '' do
      row 'English Title' do
        product_type.title_en
      end
      row 'Gujarati Title' do
        product_type.title_gu
      end
      # row 'Hindi title' do
      #   product_type.title_hi
      # end
    end
  end

  form do |f|
    inputs 'Product Type' do
      f.input :title_gu, label: 'Gujarati Title'
      f.input :title_hi, label: 'Hindi Title'
      f.input :title_en, label: 'English Title'
      f.input :image, as: :file
    end

    f.semantic_errors
    f.actions
  end
end
