class ResolutionState < ActiveRecord::Base
  has_paper_trail only: :just_with_build!, on: :update

  belongs_to :user
  belongs_to :flow
  has_many :cases

  validates_presence_of :flow
  validates :title, uniqueness: { scope: :flow_id }, length: { maximum: 100 }, presence: true
  validate :unique_by_default, if: -> { default }

  scope :active, -> { where(active: true) }

  after_create :add_resolution_on_flow
  before_update :set_flow_pending_when_have_no_default_resolution
  before_update :set_draft, unless: :draft_changed?
  before_update :remove_resolution_on_flow, if: -> { active_changed? && !active }
  before_destroy :remove_resolution_on_flow

  def add_resolution_on_flow
    resolution_versions = get_flow.resolution_states_versions.dup
    resolution_versions.merge!(id.to_s => nil)
    get_flow.update! updated_by: user, resolution_states_versions: {}
    get_flow.update! updated_by: user, resolution_states_versions: resolution_versions
  end

  def set_draft
    get_flow.update! updated_by: user, draft: true
    self.draft = true
  end

  def remove_resolution_on_flow
    resolution_versions = get_flow.resolution_states_versions.dup
    resolution_versions.delete(id.to_s)
    get_flow.update! updated_by: user, resolution_states_versions: {}
    get_flow.update! updated_by: user, resolution_states_versions: resolution_versions
  end

  def inactive!
    versions.present? ? update!(active: false) : destroy!
  end

  private

  def unique_by_default
    return if get_flow.blank?
    resolution_default = get_flow.resolution_states.where(default: true).select do |resolution|
                           resolution.id != id
                         end
    errors.add(:default, :taken) if resolution_default.present?
  end

  def set_flow_pending_when_have_no_default_resolution
    return if get_flow.blank?
    flow_status = get_flow.resolution_states.find_by(default: true).blank? ? 'pending' : 'active'
    get_flow.update(status: flow_status, updated_by: user) if get_flow.status != flow_status
  end

  def get_flow(object = nil)
    @get_flow ||= object || flow
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
    expose :default
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :default
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
  end
end
