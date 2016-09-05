class Reports::CustomField < Reports::Base
  self.table_name = 'reports_custom_field'
  include PgSearch

  belongs_to :category_custom_fields,
    class_name: 'Reports::CategoryCustomField',
    foreign_key: 'reports_custom_field_id',
    inverse_of: :custom_field,
    autosave: true

  has_many :categories,
    class_name: 'Reports::Category',
    through: :category_custom_fields

  validates :title, presence: true
  before_validation :normalize_multiline

  pg_search_scope :search_by_title,
    against: [:title],
    using: {
      tsearch: { prefix: true }
    }

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :multiline
  end

  private

  def normalize_multiline
    self.multiline = false if multiline.nil?

    true
  end
end
