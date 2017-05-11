class Reports::Phraseology < Reports::Base
  include NamespaceFilterable

  scope :search_by_category, ->(id) { where(reports_category_id: [id, nil]) }

  belongs_to :category,
    class_name: 'Reports::Category',
    foreign_key: 'reports_category_id'

  belongs_to :namespace

  validates :title, :description, presence: true

  def category_title
    category ? category.title : nil
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :description

    expose :category do |object, _|
      if category = object.category
        category.entity(only: [:id, :title])
      end
    end
  end
end
