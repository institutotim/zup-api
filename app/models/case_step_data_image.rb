class CaseStepDataImage < ActiveRecord::Base
  include EncodedImageUploadable
  mount_uploader :image, ImageUploader

  expose_multiple_versions :image

  belongs_to :case_step_data_field

  def url
    image.url
  end

  class Entity < Grape::Entity
    expose :id
    expose :url
    expose :image_structure, as: :versions
  end
end
