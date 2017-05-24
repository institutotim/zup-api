class EventLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :namespace

  class Entity < Grape::Entity
    expose :id
    expose :user, using: User::Entity
    expose :namespace, using: Namespace::Entity
    expose :headers
    expose :url
    expose :request_method
    expose :request_body
    expose :created_at
    expose :updated_at
  end
end
