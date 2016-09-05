class Namespace < ActiveRecord::Base
  scope :search_by_id, ->(ids) { where(id: Array(ids)) }
  scope :default, -> { where(default: true) }

  has_many :groups
  has_many :users

  validates :name, presence: true

  class Entity < Grape::Entity
    expose :id
    expose :name
  end
end
