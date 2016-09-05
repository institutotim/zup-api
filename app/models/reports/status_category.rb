class Reports::StatusCategory < Reports::Base
  # I added this because the id primary key field
  # was added later.
  self.primary_key = 'id'
  self.table_name = 'reports_statuses_reports_categories'

  include NamespaceFilterable

  belongs_to :category, class_name: 'Reports::Category',
                        foreign_key: 'reports_category_id',
                        touch: true

  belongs_to :status, class_name: 'Reports::Status',
                      foreign_key: 'reports_status_id'

  belongs_to :flow
  belongs_to :namespace

  belongs_to :responsible_group, class_name: 'Group',
             foreign_key: 'responsible_group_id'

  before_validation :set_default_attributes

  validates :initial, inclusion: { in: [false, true] }
  validates :final, inclusion: { in: [false, true] }
  validates :active, inclusion: { in: [false, true] }
  validates :private, inclusion: { in: [false, true] }
  validates :status, uniqueness: { scope: [:reports_category_id, :namespace_id] }
  validates :namespace, presence: true
  validates :color, presence: true, css_hex_color: true

  scope :final, -> { where(final: true) }
  scope :initial, -> { where(initial: true) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  scope :all_public, -> { where(private: false) }
  scope :all_private, -> { where(private: true) }

  scope :with_status, -> (status) { find_by(reports_status_id: status.id) }

  scope :in_progress, -> {
    where(table_name => {
      final: false
    })
  }

  class Entity < Grape::Entity
    delegate :id, :title, to: :status, allow_nil: true

    expose :id
    expose :title
    expose :color
    expose :initial
    expose :final
    expose :active
    expose :private

    expose :flow do |obj, _|
      if obj.flow
        {
          id: obj.flow.id,
          title: obj.flow.title
        }
      end
    end

    expose :responsible_group, using: Group::Entity
    expose :responsible_group_id
    expose :namespace, using: Namespace::Entity

    def status
      object.status
    end
  end

  private

  def set_default_attributes
    self.initial = status.initial if initial.nil?
    self.final = status.final if final.nil?
    self.active = status.active if active.nil?
    self.private = status.private if private.nil?
    self.color = status.color if color.nil?

    true
  end
end
