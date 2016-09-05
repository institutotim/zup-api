class Reports::Image < Reports::Base
  belongs_to :item, foreign_key: 'reports_item_id'

  mount_uploader :image, ImageUploader

  after_commit :set_date

  def url
    image.url
  end

  class Entity < Grape::Entity
    expose :title
    expose :date
    expose :url
  end

  private

  def set_date
    if image && (date.blank? || image_changed?)
      ExtractDateFromImage.perform_async(id)
    end
  end
end
