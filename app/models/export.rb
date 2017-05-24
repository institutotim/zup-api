class Export < ActiveRecord::Base
  include NamespaceFilterable

  store_accessor :filters

  belongs_to :inventory_category,
    class_name: 'Inventory::Category',
    foreign_key: 'inventory_category_id'

  belongs_to :user

  belongs_to :namespace

  validates :user, :kind, presence: true
  validates :inventory_category, presence: true, if: :inventory?

  enum kind: { report: 0, inventory: 1 }
  enum status: { pendent: 0, processed: 1, failed: 2 }

  mount_uploader :file, ExportUploader

  def kind_humanize
    inventory? ? 'Inventários' : 'Relatos'
  end

  def url
    file.url
  end

  class Entity < Grape::Entity
    expose :id
    expose :kind
    expose :status
    expose :url
    expose :created_at
    expose :inventory_category, as: :category, using: Inventory::Category::Entity
  end
end
