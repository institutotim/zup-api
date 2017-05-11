class Field < ActiveRecord::Base
  include StoreAccessorTypes

  store_accessor :requirements, :presence, :minimum, :maximum
  store_accessor :values
  has_paper_trail only: :just_with_build!, on: :update

  VALID_TYPES = %w(angle date time date_time cpf cnpj url email image attachment text integer decimal
                   meter centimeter kilometer year month day hour minute second previous_field
                   radio select checkbox inventory_item inventory_field report_item)

  belongs_to :user # who created the Field
  belongs_to :step
  has_many :case_step_fields
  belongs_to :category_inventory_field, class_name: 'Inventory::Field',
             foreign_key: :origin_field_id

  default_scope -> { order(id: :asc) }
  scope :active,    -> { where(active: true) }
  scope :requireds, -> { where("requirements -> 'presence' = 'true'") }

  validates_presence_of :title, :step, :user
  validates :field_type, inclusion: { in: VALID_TYPES }
  validates :origin_field_id, presence: true, if: -> { %w{previous_field inventory_field}.include? field_type }
  validates :values, presence: true, if: -> { %w{checkbox radio select}.include? field_type }
  validates :field_id, presence: true, if: -> { field_type == 'inventory_field' }
  validate :inventory_item_valid?, if: -> { field_type == 'inventory_field' }

  after_commit :add_field_to_step_field_versions!, on: :create
  before_save :set_origin_field_version, if: :origin_field_id?
  before_update :set_draft, unless: :draft_changed?
  before_update :remove_step_on_flow, if: -> { active_changed? && !active }
  before_destroy :remove_step_on_flow

  def self.update_order!(ids, _user = nil)
    step      = find(ids.first).step
    fields    = step.fields_versions

    order_ids = ids.inject({}) do |ids, id|
      ids[id.to_s] = fields[id.to_s]
      ids
    end

    step.update! fields_versions: {}
    step.update! fields_versions: order_ids
  end

  def category_inventory
    Inventory::Category.includes(
      :namespace, :statuses, sections: [fields: :field_options]
    ).where(id: category_inventory_id)
  end

  def category_report
    Reports::Category.where(id: category_report_id)
  end

  def values=(values)
    if field_type == 'report_item'
      self.category_report_id = values.map(&:to_i)
    elsif field_type == 'inventory_item'
      self.category_inventory_id = values.map(&:to_i)
    else
      super(values)
    end
  end

  def values
    if field_type == 'report_item'
      category_report_id
    elsif field_type == 'inventory_item'
      category_inventory_id
    else
      super
    end
  end

  def inactive!
    versions.present? ? update!(active: false) : destroy!
  end

  def get_flow(object = nil)
    @get_flow ||= object || step.flow
  end

  def required?
    requirements.present? && requirements['presence'] == 'true'
  end

  private

  def inventory_item_valid?
    if field_id
      field = Field.find(field_id)

      if field.category_inventory.size != 1 || field.multiple
        errors.add(:field_id, I18n.t(:invalid_inventory_item_field))
      end
    end
  end

  def previous_field
    return if field_type != 'previous_field'
    origin_field_version.blank? ? Field.find_by(id: origin_field_id) : Version.reify(origin_field_version)
  end

  def previous_field_step_id
    return if field_type != 'previous_field'
    field = origin_field_version.blank? ? Field.find_by(id: origin_field_id) : Version.reify(origin_field_version)
    field.step.try(:id)
  end

  def set_origin_field_version
    return if field_type != 'previous_field' || origin_field_version.present?
    field = Field.find_by(id: origin_field_id)
    self.origin_field_version = field.versions.try(:last).try(:id)

    true
  end

  def category_inventory_field
    return if field_type != 'inventory_field'
    super
  end

  def add_field_to_step_field_versions!
    fields_versions = step.fields_versions.merge(id.to_s => nil)
    step.update!(user: user, fields_versions: fields_versions)
  end

  def set_draft
    get_flow.update!(updated_by: user, draft: true)
    step.update!(draft: true)
    self.draft = true
  end

  def remove_step_on_flow
    field_versions = step.fields_versions.dup
    field_versions.delete(id.to_s)
    step.update! user: user, fields_versions: {}
    step.update! user: user, fields_versions: field_versions
  end

  # used on Entity
  def list_versions
    versions.map(&:reify) if versions.present?
  end

  def version_id
    version.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :field_type
    expose :filter
    expose :origin_field_id
    expose :origin_field_version
    expose :category_inventory, using: Inventory::Category::Entity
    expose :category_inventory_field, using: Inventory::Field::Entity
    expose :category_report, using: Reports::Category::Entity
    expose :requirements
    expose :multiple
    expose :values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
    expose :previous_field_step_id
    expose :field_id
    expose :previous_field, using: Field::EntityVersion
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :field_type
    expose :filter
    expose :origin_field_id
    expose :origin_field_version
    expose :category_inventory, using: Inventory::Category::Entity
    expose :category_inventory_field, using: Inventory::Field::Entity
    expose :category_report, using: Reports::Category::Entity
    expose :requirements
    expose :multiple
    expose :values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
    expose :previous_field_step_id
    expose :field_id
    expose :previous_field, using: Field::Entity
  end
end
