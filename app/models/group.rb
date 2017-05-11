class Group < ActiveRecord::Base
  include MemoryCache
  include PgSearch

  belongs_to :namespace
  has_and_belongs_to_many :users, uniq: true
  has_one :permission, class_name: 'GroupPermission', autosave: true

  validates :name, presence: true, uniqueness: { scope: :namespace_id }
  validates :guest, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  after_destroy :remove_reports_categories_connections

  scope :guest, -> { where(guest: true) }
  default_scope -> { order('groups.id ASC') }

  with_options using: { tsearch: { prefix: true } }, ignoring: :accents do |o|
    o.pg_search_scope :search_by_name, against: :name
    o.pg_search_scope :search_by_user_name, associated_against: { users: :name }
  end

  def self.with_permission(permission_name)
    joins(:permission)
      .where(group_permissions: { permission_name => true }).first
  end

  def self.that_includes_permission(permission_name, id, namespace_id = nil)
    query = includes(:permission)
    query = query.where(namespace_id: namespace_id) if namespace_id
    query.select do |group|
      group.permission.send(permission_name).include?(id)
    end
  end

  def self.ids_for_permission(groups, permission_name)
    groups.inject([]) do |permissions, group|
      permissions += group.permission.send(permission_name)
    end
  end

  def self.included_in_permission?(groups, permission_name, id)
    permission_array = ids_for_permission(groups, permission_name)
    permission_array.include?(id)
  end

  def remove_reports_categories_connections
    transaction do
      Reports::Category.where(default_solver_group_id: id).update_all(default_solver_group_id: nil)
      Reports::CategorySetting.where(default_solver_group_id: id).update_all(default_solver_group_id: nil)
      Reports::CategorySetting.where('? = ANY(solver_groups_ids)', id).each do |category_setting|
        category_setting.solver_groups -= [self]
        category_setting.save!
      end
      Reports::Category.where('? = ANY(solver_groups_ids)', id).each do |category|
        category.solver_groups -= [self]
        category.save!
      end
    end
  end

  def to_s
    "Group: #{name} (#{id})"
  end

  def typed_permissions
    if permission.present?
      typed_permissions = {}

      GroupPermission.permissions_columns.each do |c|
        typed_permissions[c] = permission.send(c)
      end

      return typed_permissions.with_indifferent_access
    end

    {}
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :typed_permissions, as: :permissions
    expose :users, using: User::Entity, unless: { collection: true }
    expose :namespace, using: Namespace::Entity
  end

  private

  def set_default_attributes
    self.guest = false if guest.nil?
    build_permission unless permission.present?
  end
end
