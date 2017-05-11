class Namespace < ActiveRecord::Base
  scope :search_by_id, ->(ids) { where(id: Array(ids)) }
  scope :default, -> { where(default: true) }

  has_many :groups
  has_many :users

  validates :name, presence: true

  def self.global_namespace_id
    @global_namespace_id ||= default.first.try(:id)
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
  end
end
