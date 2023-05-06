module Api
  module V1
    class CropCategoriesController < Api::V1::ApiController
      before_action :set_attribute

      def index
        crop_categories = CropCategory.pluck("id, #{@name}").to_h
        render_json(t('crop.index.message'), crop_categories: crop_categories)
      end

      def with_crops
        crop_categories = if params[:crop_category_id].present?
                            CropCategory.where(id: params[:crop_category_id])
                          else
                            CropCategory.all
                          end

        crop_categories = crop_categories.order(Arel.sql('case ' \
                                                        "when crop_categories.name_en ILIKE '%monsoon%' then 1 " \
                                                        "when crop_categories.name_en ILIKE '%winter%' then 2 " \
                                                        "when crop_categories.name_en ILIKE '%summer%' then 3 " \
                                                        'end'))
                                         .joins(:crops)
                                         .joins('INNER JOIN active_storage_attachments on active_storage_attachments.record_id = crops.id ' \
                                                "and active_storage_attachments.record_type = 'Crop'")
                                         .where('crops.name_en ILIKE :search OR crops.name_gu ILIKE :search OR ' \
                                                'crops.name_hi ILIKE :search', search: "%#{params[:search]}%")
                                         .select("active_storage_attachments.blob_id, crop_categories.id, crop_categories.#{@name}," \
                                                 "crops.id As crop_id, crops.#{@name} AS crop_name")

        crops_categories = []
        crop_categories.each do |crop_category|
          crop = crops_categories.find { |c| c[:id] == crop_category.id.to_s }
          unless crop.present?
            crops_categories << { id: crop_category.id.to_s, name: crop_category[@name], crops: [] }
            crop = crops_categories.last
          end
          crop[:crops] << { id: crop_category.crop_id.to_s, name: crop_category.crop_name,
                            image_url: public_url(ActiveStorage::Blob.find(crop_category.blob_id)) }
        end

        # crop_categories = crop_categories.joins(:crops).where('crops.name_en ILIKE :search OR crops.name_gu ILIKE :search OR ' \
        #                                             'crops.name_hi ILIKE :search', search: "%#{params[:search]}%").uniq
        # crops_categories = []
        # crop_categories.each do |crop_category|
        #   crops_categories << { id: crop_category.id.to_s, name: crop_category[@name], crops: [] }
        #   crops = []
        #   c = crop_category.crops.where('crops.name_en ILIKE :search OR crops.name_gu ILIKE :search OR ' \
        #                                 'crops.name_hi ILIKE :search', search: "%#{params[:search]}%")
        #                    .includes([image_attachment: :blob])
        #   c.each do |crop|
        #     crops << { id: crop.id.to_s, name: crop[@name], image_url: crop.image_url }
        #   end

        #   crops_categories.last['crops'] = crops
        # end
        render_json(t('crop.index.message'), crop_categories: crops_categories)
      end

      private

      def set_attribute
        if current_user.gujarati?
          @name = 'name_gu'
        elsif current_user.english?
          @name = 'name_en'
        elsif current_user.hindi?
          @name = 'name_hi'
        end
      end
    end
  end
end
