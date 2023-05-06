module Api
  module V1
    class ProductTypesController < Api::V1::ApiController
      before_action :set_attribute, only: %i[index show]

      def index
        products = ProductType.all.includes(image_attachment: :blob)
        if products.exists?
          products = ProductTypeSerializer.new(products, { params: { title: @title } }).serializable_hash
          render_json(t('p_type.message'), { products: products[:data] })
        else
          render_json(t('p_type.error'))
        end
      end

      private

      def set_attribute
        if current_user.gujarati?
          @title = 'title_gu'
        elsif current_user.english?
          @title = 'title_en'
        elsif current_user.hindi?
          @title = 'title_hi'
        end
      end
    end
  end
end
