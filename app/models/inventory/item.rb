class Inventory::Item < Inventory::Base
  include PgSearch
  include BoundaryValidation
  include NamespaceFilterable

  scope :locked, -> { where(locked: true) }

  with_options using: { tsearch: { prefix: true } }, ignoring: :accents do |o|
    o.pg_search_scope :search_by_query, against: [:sequence, :address, :title], associated_against: {
                                        user: [:name]
                                      }
    o.pg_search_scope :search_by_title, against: :title
    o.pg_search_scope :search_by_address, against: :address
  end

  set_rgeo_factory_for_column(:position, RGeo::Geographic.simple_mercator_factory)

  belongs_to :user
  belongs_to :category, class_name: 'Inventory::Category', foreign_key: 'inventory_category_id'
  belongs_to :namespace
  belongs_to :status, class_name: 'Inventory::Status', foreign_key: 'inventory_status_id'
  belongs_to :locker, class_name: 'User'

  has_many :data, class_name: 'Inventory::ItemData',
                  foreign_key: 'inventory_item_id',
                  autosave: true,
                  dependent: :destroy

  has_many :fields, class_name: 'Inventory::Field',
                    through: :category

  has_many :field_options, class_name: 'Inventory::FieldOption',
                     through: :fields

  has_many :selected_options, class_name: 'Inventory::FieldOption',
                     through: :data,
                     source: :option
  has_many :histories, class_name: 'Inventory::ItemHistory',
                       foreign_key: 'inventory_item_id',
                       dependent: :destroy
  has_many :images, class_name: 'Inventory::ItemDataImage',
                    through: :data

  before_validation :update_position_from_data
  before_validation :generate_title

  validates :category, :namespace, presence: true
  validates :user, presence: true
  validates :title, presence: true
  validates :status, presence: true, if: :must_have_status?

  validate_in_boundary :position

  def location
    @location ||= Hash[
      data.joins { field }
               .where { field.title >> ['latitude', 'longitude', 'address'] }
               .map do |item_data|
                 [item_data.field.title.to_sym, item_data.content]
               end
    ]

    @location[:latitude] = @location[:latitude].to_f
    @location[:longitude] = @location[:longitude].to_f

    @location
  end

  def data_value_as_title
    title_field = fields.find_by(use_as_title: true)
    data.find_by(inventory_field_id: title_field.id).try(:content) if title_field
  end

  def title
    data_value_as_title || super
  end

  def related_entities
    Cases::RelatedEntities.new(self)
  end

  class Entity < Grape::Entity
    include GrapeEntityHelper

    expose :id
    expose :title do |obj, _|
      "##{obj.sequence} #{obj.data_value_as_title}" || "##{obj.sequence}"
    end
    expose :address
    expose :inventory_status_id
    expose :status, using: Inventory::Status::Entity
    expose :locked
    expose :locker_id
    expose :locked_at
    expose :related_entities, using: Cases::RelatedEntities::Entity

    # TODO: Find out why this is happening
    expose :position do |obj, _|
      if obj.respond_to?(:position) && !obj.position.nil?
        { latitude: obj.position.y, longitude: obj.position.x }
      end
    end

    with_options(if: { display_type: 'full' }) do
      expose :user, using: User::Entity
      expose :category, using: Inventory::Category::Entity
    end

    expose :inventory_category_id
    expose :data, unless: { collection: true }
    expose :created_at
    expose :updated_at

    private

    def data
      user = options[:user]
      objects = object.data.preload(field: :field_options)

      permissions = UserAbility.for_user(user)

      unless permissions.can?(:manage, Inventory::Item) || permissions.can?(:edit, object.category) || (permissions.can?(:create, object.category) && object.user.id == user.id)
        ids = permissions.inventory_fields_visible
        objects = objects.where(inventory_field_id: ids)
      end

      options = extract_options_for(:data)

      Inventory::ItemData::Entity.represent(objects, options)
    end
  end

  # Data with Inventory::ItemDataRepresenter
  def represented_data(user = nil)
    @represented_data ||= Inventory::ItemDataRepresenter.factory(self, user)
  end

  private

  def must_have_status?
    category && category.require_item_status?
  end

  # TODO: Singularize portuguese words
  def generate_title
    if data_value_as_title
      self.title = data_value_as_title
    elsif category && (new_record?)
      self.title = category.title
    end
  end

  # TODO: This should be in the representer class
  def update_position_from_data
    latitude, longitude, dynamic_address = nil

    # TODO: Find a way to select the data with
    # location fields, automatically.
    data.each do |data|
      next unless data.field.present?
      next unless data.field.location

      if data.field.title == 'latitude'
        latitude = data.content
      elsif data.field.title == 'longitude'
        longitude = data.content
      elsif data.field.title == 'address'
        dynamic_address = data.content
      end
    end

    if !position_changed? && latitude && longitude
      self.position = ::Reports::Item.rgeo_factory.point(longitude, latitude)
    end

    if !self.address_changed? && dynamic_address
      self.address = dynamic_address
    end
  end
end
