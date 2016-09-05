class Reports::OffensiveFlag < Reports::Base
  belongs_to :item, foreign_key: :reports_item_id
  belongs_to :user

  validates :item, presence: true
  validates :user, presence: true, uniqueness: { scope: :reports_item_id }

  scope :in_last_hour, -> { where('created_at > ?', 1.hour.ago) }

  def self.for(user, item)
    by_user(user).find_by(
      reports_item_id: item.id
    )
  end

  def self.by_user(user)
    where(
      user_id: user.id
    )
  end

  class Entity < Grape::Entity
    expose :id
    expose :user, using: User::Entity
    expose :created_at
    expose :updated_at
  end
end
