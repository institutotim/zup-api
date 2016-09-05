module Reports
  class CategoryPerimeter < Reports::Base
    self.table_name = 'reports_categories_perimeters'

    default_scope { order(priority: :desc, created_at: :asc) }
    scope :actives, -> { where(active: true) }

    belongs_to :category,
      class_name: 'Reports::Category',
      foreign_key: 'reports_category_id'

    belongs_to :group,
      foreign_key: 'solver_group_id'

    belongs_to :namespace

    belongs_to :perimeter,
      class_name: 'Reports::Perimeter',
      foreign_key: 'reports_perimeter_id'

    validates :category, :perimeter, :group, :priority, :namespace, presence: true
    validates :priority, numericality: { greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100 }

    delegate :title, to: :perimeter

    class Entity < Grape::Entity
      expose :id
      expose :category, using: Reports::Category::Entity
      expose :group, using: Group::Entity
      expose :perimeter, using: Reports::Perimeter::Entity
      expose :priority
      expose :active
      expose :created_at
      expose :updated_at
    end
  end
end
