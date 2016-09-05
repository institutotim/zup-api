class Reports::Comment < Reports::Base
  VISIBILITY = [
    PUBLIC = 0,
    PRIVATE = 1,
    INTERNAL = 2
  ]

  class Entity < Grape::Entity
    expose :id
    expose :reports_item_id
    expose :visibility
    expose :author, using: User::Entity
    expose :message

    expose :created_at
  end

  scope :external, -> { where(visibility: [0, 1]) }

  belongs_to :item, foreign_key: 'reports_item_id', class_name: 'Reports::Item',
             counter_cache: :comments_count
  belongs_to :author, class_name: 'User'

  validates :message, presence: true
  validates :visibility, presence: true, inclusion: { in: VISIBILITY }
  validates_associated :item

  before_validation :set_default_values

  scope :with_visibility, -> (visibility) { where('visibility <= ?', visibility) }

  private

  def set_default_values
    self.visibility = PUBLIC if visibility.nil?
  end
end
