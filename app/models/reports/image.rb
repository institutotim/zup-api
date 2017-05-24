class Reports::Image < Reports::Base
  belongs_to :item, foreign_key: 'reports_item_id'

  enum visibility: { visible: 0, internal: 1 }
  enum origin: { citizen: 0, fiscal: 1 }

  mount_uploader :image, ImageUploader

  after_commit :set_date

  def url
    image.url
  end

  def high_url
    image.url(:high)
  end

  def low_url
    image.url(:low)
  end

  def thumb_url
    image.url(:thumb)
  end

  def filename
    image.file.filename
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :date
    expose :origin
    expose :visibility
    expose :url, as: :original
    expose :high_url, as: :high
    expose :low_url, as: :low
    expose :thumb_url, as: :thumb
  end

  private

  def set_date
    if image && (date.blank? || image_changed?)
      ExtractDateFromImage.perform_async(id)
    end
  end
end
