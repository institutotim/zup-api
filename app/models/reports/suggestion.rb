class Reports::Suggestion < Reports::Base
  include NamespaceFilterable

  scope :search_by_ids, ->(id) { where('? = ANY(reports_items_ids::int[])', id) }
  scope :by_categories, ->(*ids) { where(reports_category_id: ids) }

  belongs_to :category,
    class_name: 'Reports::Category',
    foreign_key: :reports_category_id

  belongs_to :item,
    class_name: 'Reports::Item',
    foreign_key: :reports_item_id

  belongs_to :namespace

  enum status: { active: 0, ignored: 1, grouped: 2 }

  validates :address, :reports_category_id, :reports_item_id, :reports_items_ids,
    presence: true
  validate :uniqueness_of_suggestion, on: :create

  class Entity < Grape::Entity
    expose :id
    expose :category, using: Reports::Category::Entity
    expose :address
    expose :status
    expose :reports_items_ids
  end

  private

  def uniqueness_of_suggestion
    if self.class.search_by_ids(reports_item_id).any?
      errors.add(:reports_items_ids, :taken)
    end
  end
end
