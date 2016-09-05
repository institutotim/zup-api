class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :chattable, polymorphic: true
  has_many :notifications, as: :notificable

  enum kind: [:user, :system]

  validates_presence_of :chattable_id, :chattable_type, :kind, :text
  validates_presence_of :user_id, if: :from_a_user?

  private

  def from_a_user?
    kind == 'user'
  end

  class Entity < Grape::Entity
    expose :id
    expose :chattable_id
    expose :chattable_type, unless: { basic: true } do |instance, _|
      instance.chattable_type.underscore
    end
    expose :chattable, unless: { basic: true } do |instance, _|
      instance.chattable.entity
    end
    expose :kind
    expose :text
    expose :created_at
    expose :user, with: User::Entity, if: lambda { |instance, _opts| instance.kind == 'user' }
  end
end
