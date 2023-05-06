module Api
  module V1
    class ProductsController < Api::V1::ApiController
      before_action :set_attribute, only: %i[index show taged_products]

      def index
        products = Product.where(product_type_id: params[:product_type_id], active: true)
                          .where('title_en ILIKE :search OR title_gu ILIKE :search OR title_hi ILIKE :search',
                                 search: "%#{params[:search]}%").includes(:product_type).order(:priority)
        if products.present?
          products = ProductSerializer.new(products, { params: { title: @title, description: @description,
                                                                 other_details: @other_details } }).serializable_hash
          render_json(t('product.message'), { products: products[:data] })
        else
          render_json(t('product.error'))
        end
      end

      def show
        product = Product.find_by(id: params[:id], active: true)
        return render_404(t('product.error')) unless product.present?

        product_uniqueness = ProductUniquenessSerializer.new(product.product_uniquenesses,
                                                             params: { title: @title, description: @description,
                                                                       sub_title: @sub_title }).serializable_hash[:data]
        products = ProductSerializer.new(product, params: { title: @title, description: @description,
                                                            other_details: @other_details }).serializable_hash
        products[:data][:attributes].merge!(product_uniquenesses: product_uniqueness)
        render_json(t('product.message'), { product: products[:data] })
      end

      def taged_products
        if params[:tags].present?
          products = Product.where(id: params[:tags], active: true).includes(:product_type)
          if products.present?
            products = ProductSerializer.new(products, { params: { title: @title, description: @description,
                                                                   other_details: @other_details } }).serializable_hash
            render_json(t('product.message'), { products: products[:data] })
          else
            render_json(t('product.error'))
          end
        else
          render_400(t('product.tag_error'))
        end
      end

      private

      def set_attribute
        if current_user.gujarati?
          @title = 'title_gu'
          @description = 'description_gu'
          @other_details = 'other_details_gu'
          @sub_title = 'sub_title_gu'
        elsif current_user.english?
          @title = 'title_en'
          @description = 'description_en'
          @other_details = 'other_details_en'
          @sub_title = 'sub_title_en'
        elsif current_user.hindi?
          @title = 'title_hi'
          @description = 'description_hi'
          @other_details = 'other_details_hi'
          @sub_title = 'sub_title_hi'
        end
      end
    end
  end
end
