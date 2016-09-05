class BusinessReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :namespace
  include NamespaceFilterable

  validates :title, presence: true
  validates :user,  presence: true
  validates :params, presence: true

  default_scope -> { order(id: :desc) }

  class Entity < Grape::Entity
    expose :id
    expose :user, using: User::Entity
    expose :title
    expose :summary
    expose :params
    expose :created_at
    expose :namespace, using: Namespace::Entity
  end
end
