class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notificable, polymorphic: true

  validates_presence_of :notificable_id, :notificable_type, :title, :description, :user_id

  default_scope { order(created_at: :desc) }
  scope :unread, -> { where(read: false) }

  def self.read_all!
    where(read: false).each do |notification|
      notification.read!
    end
  end

  def read!
    if !read
      self.read = true
      self.read_at = Time.now
      self.save!
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :user_id
    expose :title
    expose :description
    expose :notificable_id
    expose :notificable_type do |instance, _|
      instance.notificable_type.underscore
    end
    expose :read
    expose :read_at
    expose :created_at
  end
end
