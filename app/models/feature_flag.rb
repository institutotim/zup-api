class FeatureFlag < ActiveRecord::Base
  validates :name, presence: true
  validates :status, presence: true

  enum status: [:disabled, :enabled]

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :status
  end
end
