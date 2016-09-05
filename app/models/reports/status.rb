class Reports::Status < Reports::Base
  has_and_belongs_to_many :categories,
    class_name: 'Reports::Category',
    join_table: 'reports_statuses_reports_categories',
    foreign_key: 'reports_status_id',
    association_foreign_key: 'reports_category_id'

  has_many :reports_items, class_name: 'Reports::Item', foreign_key: 'reports_status_id'

  has_many :status_categories,
    class_name: 'Reports::StatusCategory',
    foreign_key: 'reports_status_id'
  has_many :categories,
    class_name: 'Reports::Category',
    through: :status_categories,
    source: :category

  validates :title, presence: true, uniqueness: true
  validates :initial, inclusion: { in: [false, true] }
  validates :final, inclusion: { in: [false, true] }
  validates :active, inclusion: { in: [false, true] }
  validates :private, inclusion: { in: [false, true] }

  before_validation :set_default_attributes

  scope :final, -> { where(final: true) }
  scope :initial, -> { where(initial: true) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :all_public, -> { where(private: false) }

  # Check if the status is private for
  # the report category.
  #
  # Because we won't send any emails for the user
  # if it's private, you know.
  def private_for_category?(category, namespace_id)
    Reports::StatusCategory.all_private.find_by(
      reports_status_id: id,
      reports_category_id: category.id,
      namespace_id: namespace_id
    ).present?
  end

  def for_category(category, namespace_id)
    category.status_categories.find_by(
      reports_status_id: id,
      namespace_id: namespace_id
    )
  end

  class Entity < Grape::Entity
    expose :id
    expose :private
    expose :title
    expose :color
    expose :initial
    expose :final
    expose :active

    with_options(if: { display_type: :full }) do
      expose :created_at
      expose :updated_at
    end
  end

  private

  def set_default_attributes
    self.initial = false if initial.nil?
    self.final = false if final.nil?
    self.active = true if active.nil?
    self.private = false if private.nil?

    true
  end
end
