class User < ActiveRecord::Base
  include PgSearch
  include PasswordAuthenticable
  include Unsubscribeable

  attr_accessor :from_webhook, :ignore_password_requirement

  scope :enabled, -> { where(disabled: false) }

  with_options ignoring: :accents do |o|
    o.pg_search_scope :search_by_query, against: [:email, :name, :document],
      using: { tsearch: { prefix: true, tsvector_column: :tsv_query },
      trigram: { only: [:email] } }

    o.pg_search_scope :search_by_email, against: :email,
      using: { trigram: { threshold: 0.2 } }, ranked_by: ':trigram'

    o.pg_search_scope :search_by_name, against: :name,
      using: { tsearch: { prefix: true, tsvector_column: :tsv_name } }

    o.pg_search_scope :search_by_document, against: :document,
      using: { tsearch: { prefix: true, tsvector_column: :tsv_document } }
  end

  belongs_to :namespace
  has_one :permission, class_name: 'GroupPermission', autosave: true
  has_one :token, -> { where(permanent: true) }, class_name: 'AccessKey'
  has_many :access_keys
  has_many :reports, class_name: 'Reports::Item', foreign_key: 'user_id'
  has_and_belongs_to_many :groups, uniq: true
  has_many :groups_permissions, through: :groups,
                                class_name: 'GroupPermission',
                                source: :permission
  has_many :feedbacks, class_name: 'Reports::Feedback'
  has_many :flows, class_name: 'Flow', foreign_key: :created_by_id
  has_many :cases, class_name: 'Case', foreign_key: :created_by_id
  has_many :cases_log_entries
  has_many :cases_log_entries_as_before_user, class_name: 'CasesLogEntry', foreign_key: :before_user_id
  has_many :cases_log_entries_as_after_user, class_name: 'CasesLogEntry', foreign_key: :after_user_id
  has_many :chat_messages
  has_many :notifications

  EMAIL_REGEXP = /\A(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|
                    ([A-Za-z0-9]+\++))*[A-Z<200c><200b>a-z0-9_]+@((\w+\-+)|
                    (\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}\z/x

  validates :email, uniqueness: true,
                    format: { with: EMAIL_REGEXP },
                    allow_blank: true

  validates :email, presence: true, unless: :service?

  validates :name, presence: true, length: { in: 4..64 }

  validates :encrypted_password, :phone, :document, :address, :postal_code,
            :district, :city, :namespace, presence: true, unless: :skip_validations?

  validates :document, uniqueness: true, on: :create, unless: :skip_validations?

  before_create :generate_access_key!, :create_permission

  enum kind: { user: 0, service: 1 }

  def self.authorize(token)
    if ak = AccessKey.active.find_by(key: token)
      User.unscoped { ak.user }
    else
      nil
    end
  end

  def last_access_key
    access_keys.active.last.key
  end

  def generate_access_key!(long_lived = false)
    expiration_date = long_lived ? AccessKey.long_lived_duration : AccessKey.short_lived_duration
    permanent = service?

    params = { expires_at: expiration_date, permanent: permanent }

    if self.new_record?
      access_keys.build(params)
    else
      access_keys.create(params)
    end
  end

  def to_json(options = {})
    options[:except] ||= [:encrypted_password, :salt]
    super(options)
  end

  def skip_validations?
    service? || from_webhook
  end

  def ignore_password_requirement?
    service? || ignore_password_requirement
  end

  def guest?
    false
  end

  def disable!
    update!(disabled: true)
  end

  def enable!
    update!(disabled: false)
  end

  def enabled?
    !disabled?
  end

  def group_ids
    if ENV['DISABLE_MEMORY_CACHE'] == 'true'
      groups.pluck(:id)
    else
      @group_ids ||= groups.pluck(:id)
    end
  end

  # Compile all user permissions from group
  def permissions
    BuildPermissions.new(self).permissions
  end

  def groups_names
    if groups.any?
      groups.map(&:name)
    else
      []
    end
  end

  def push_notification_available?
    device_type && device_token
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :email
    expose :disabled
    expose :groups, with: Group::Entity, unless: lambda { |_, opts| opts[:collection] == true && !opts[:show_groups] }
    expose :permissions, unless: { collection: true }
    expose :groups_names, unless: { collection: true }
    expose :namespace, using: Namespace::Entity
    expose :permanent_key, as: :token, if: lambda { |object, _| object.service?  }

    with_options(if: { display_type: 'full' }) do
      expose :email
      expose :phone
      expose :commercial_phone
      expose :skype
      expose :document
      expose :birthdate
      expose :address
      expose :address_additional
      expose :postal_code
      expose :district
      expose :city
      expose :institution
      expose :position
      expose :device_token
      expose :device_type
      expose :created_at
      expose :facebook_user_id
      expose :twitter_user_id
      expose :google_plus_user_id
    end

    with_options(if: { display_type: 'autocomplete' }) do
      expose :mention_string do |user|
        "@U#{user.id}"
      end
    end

    def permissions
      object.permissions.to_h
    end

    def permanent_key
      object.token.try(:key)
    end
  end

  class ListingEntity < Grape::Entity
    expose :id
    expose :name
  end

  class Guest < User
    def id
      -1
    end

    def groups
      Group.guest
    end

    def guest?
      true
    end

    def save
      false
    end

    def cache_key
      'user/0'
    end

    def save!
      false
    end
  end

  class Anonymous < User
    def id
      -1
    end

    def groups
      Group.guest
    end

    def name
      'Anônimo'
    end

    def disabled
      false
    end

    def email
      'anonimo@test.com'
    end
  end

  private

  def create_permission
    return if user? || permission.present?

    build_permission
  end
end
