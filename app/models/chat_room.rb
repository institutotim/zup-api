class ChatRoom < ActiveRecord::Base
  include PgSearch
  include NamespaceFilterable

  belongs_to :namespace
  has_many :chat_messages, as: :chattable
  has_many :notifications, as: :notificable

  pg_search_scope :search, against: :title, using: { tsearch: { prefix: true } }

  validates :title, :namespace, presence: true

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :namespace, using: Namespace::Entity
  end
end
