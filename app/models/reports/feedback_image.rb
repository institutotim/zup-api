class Reports::FeedbackImage < Reports::Base
  include EncodedImageUploadable
  belongs_to :reports_feedback, class_name: 'Reports::Feedback'

  validates :image, presence: true
  mount_uploader :image, ImageUploader

  expose_multiple_versions :image

  class Entity < Grape::Entity
    expose :image_structure, as: :versions
  end
end
