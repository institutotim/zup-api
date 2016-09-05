class Reports::Feedback < Reports::Base
  include EncodedImageUploadable

  accepts_multiple_images_for :images

  belongs_to :reports_item, class_name: 'Reports::Item'
  belongs_to :user

  has_many :images, class_name: 'Reports::FeedbackImage',
                    foreign_key: :reports_feedback_id

  validates :reports_item, presence: true
  validates :user, presence: true
  validates :kind, inclusion: { in: %w(positive negative) }

  class Entity < Grape::Entity
    expose :id
    expose :kind
    expose :content

    with_options(unless: { collection: true }) do
      expose :user, using: User::Entity
      expose :images, using: Reports::FeedbackImage::Entity
    end

    with_options(if: { collection: true }) do
      expose :reports_item_id
      expose :user_id
    end
  end
end
