class Reports::Category < Reports::Base
  include EncodedImageUploadable
  include SolverGroup
  include NamespaceFilterable
  include Deletable

  belongs_to :namespace

  belongs_to :parent_category,
    class_name: 'Reports::Category',
    foreign_key: 'parent_id'

  has_one :setting,
    class_name: 'Reports::CategorySetting',
    foreign_key: 'reports_category_id'

  has_and_belongs_to_many :inventory_categories,
    class_name: 'Inventory::Category',
    foreign_key: 'reports_category_id',
    association_foreign_key: 'inventory_category_id'

  has_many :category_perimeters,
    class_name: 'Reports::CategoryPerimeter',
    foreign_key: 'reports_category_id',
    dependent: :delete_all

  has_many :notification_types,
    class_name: 'Reports::NotificationType',
    foreign_key: 'reports_category_id',
    dependent: :destroy

  has_many :reports,
    class_name: 'Reports::Item',
    foreign_key: 'reports_category_id',
    dependent: :destroy

  has_many :settings,
    class_name: 'Reports::CategorySetting',
    foreign_key: 'reports_category_id',
    dependent: :destroy

  has_many :status_categories,
    class_name: 'Reports::StatusCategory',
    foreign_key: 'reports_category_id',
    dependent: :destroy

  has_many :statuses, -> { distinct },
    class_name: 'Reports::Status',
    through: :status_categories,
    source: :status

  has_many :subcategories,
    class_name: 'Reports::Category',
    foreign_key: 'parent_id'

  has_many :category_custom_fields,
    class_name: 'Reports::CategoryCustomField',
    foreign_key: 'reports_category_id',
    inverse_of: :category,
    autosave: true

  has_many :custom_fields,
    class_name: 'Reports::CustomField',
    through: :category_custom_fields,
    inverse_of: :categories,
    autosave: true

  accepts_nested_attributes_for :custom_fields, allow_destroy: true

  enum priority: [:low, :medium, :high]

  scope :active,  -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :main,    -> { where(parent_id: nil) }

  default_scope -> { order(title: :asc) }

  mount_uploader :icon, IconUploader
  mount_uploader :marker, MarkerUploader

  validates :title, presence: true, uniqueness: true
  validates :icon, integrity: true, presence: true
  validates :marker, integrity: true, presence: true
  validates :color, presence: true, css_hex_color: true
  validates :confidential, inclusion: { in: [false, true] }
  validates :resolution_time, presence: true, if: :resolution_time_enabled?

  accepts_encoded_file :icon, :marker
  expose_multiple_versions :icon, :marker

  def update_statuses!(statuses)
    Reports::ManageCategoryStatuses.new(self).update_statuses!(statuses)
  end

  def original_icon
    icon.to_s
  end

  def find_perimeter(namespace_id, latitude = nil, longitude = nil)
    return unless latitude && longitude

    category_perimeters.joins(:perimeter)
                       .where(namespace_id: namespace_id)
                       .merge(Reports::Perimeter.search(latitude, longitude))
                       .first
  end

  def custom_fields_attributes=(custom_fields_attributes)
    custom_fields_attributes.each do |custom_field_attr|
      custom_field_attr = custom_field_attr.with_indifferent_access
      if custom_field_attr[:id].blank?
        custom_fields.build(custom_field_attr)
      else
        custom_field = Reports::CustomField.find(custom_field_attr[:id])

        if custom_field_attr[:_destroy]
          if (relation = category_custom_fields.find_by(reports_custom_field_id: custom_field_attr[:id]))
            relation.destroy
          end
        else
          category_custom_fields.find_or_create_by!(reports_custom_field_id: custom_field.id)

          if custom_field.title != custom_field_attr[:title]
            custom_field.title = custom_field_attr[:title]
          end

          if custom_field.multiline != custom_field_attr[:multiline]
            custom_field.multiline = custom_field_attr[:multiline]
          end
        end

        custom_field.save!
      end
    end

    touch unless new_record?
  end

  class Entity < Grape::Entity
    delegate :resolution_time_enabled, :resolution_time, :private_resolution_time,
             :user_response_time, :allows_arbitrary_position, :confidential,
             :default_solver_group_id, :default_solver_group, :solver_groups_ids, :notifications,
             :comment_required_when_forwarding, :ordered_notifications,
             :comment_required_when_updating_status, :perimeters, :flow_id,
             :priority, to: :setting, allow_nil: true

    expose :id
    expose :title
    expose :original_icon
    expose :icon_structure, as: :icon
    expose :marker_structure, as: :marker
    expose :color
    expose :priority

    expose :priority_pretty do |instance, _|
      if !instance.try(:setting).try(:priority).nil?
        I18n.t("reports.categories.priority.#{instance.try(:setting).try(:priority)}")
      end
    end

    expose :resolution_time_enabled
    expose :resolution_time
    expose :private_resolution_time
    expose :user_response_time
    expose :allows_arbitrary_position
    expose :parent_id
    expose :status_categories, as: :statuses, using: Reports::StatusCategory::Entity
    expose :confidential
    expose :comment_required_when_updating_status
    expose :comment_required_when_forwarding
    expose :solver_groups, using: Group::Entity
    expose :solver_groups_ids
    expose :default_solver_group, using: Group::Entity
    expose :default_solver_group_id
    expose :notifications
    expose :ordered_notifications
    expose :perimeters
    expose :days_for_deletion

    expose :custom_fields, using: Reports::CustomField::Entity

    with_options(if: { display_type: :full }) do
      expose :active
      expose :inventory_categories, using: Inventory::Category::Entity
      expose :subcategories, using: Entity
      expose :created_at
      expose :updated_at
      expose :namespace, using: Namespace::Entity
    end

    def subcategories
      subcategories_scope = object.subcategories

      if options[:user]
        user_permissions = UserAbility.for_user(options[:user])

        unless user_permissions.can?(:manage, Reports::Category) || user_permissions.can?(:edit, object)
          subcategories_scope = subcategories_scope.where(id: user_permissions.reports_categories_visible)
        end
      end

      subcategories_scope
    end

    def setting
      Reports::CategorySetting.where(reports_category_id: object.id, namespace_id: @@namespace_id).first!
    end

    def namespace
      object.namespace || options[:default_namespace]
    end
  end
end
