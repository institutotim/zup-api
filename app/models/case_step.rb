class CaseStep < ActiveRecord::Base
  belongs_to :kase, class_name: 'Case', foreign_key: :case_id
  belongs_to :step
  belongs_to :trigger
  has_many :case_step_data_fields, inverse_of: :case_step
  belongs_to :created_by,        class_name: 'User',  foreign_key: :created_by_id
  belongs_to :updated_by,        class_name: 'User',  foreign_key: :updated_by_id
  belongs_to :responsible_user,  class_name: 'User',  foreign_key: :responsible_user_id
  belongs_to :responsible_group, class_name: 'Group', foreign_key: :responsible_group_id

  accepts_nested_attributes_for :case_step_data_fields

  URI_FORMAT   = /(^$)|(^(http|https|ftp|udp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
  EMAIL_FORMAT = /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/

  validate :fields_of_step, if: -> { executed? }
  validate :step_id, presence: true, uniqueness: { scope: :case_id }
  validate :case_id
  after_commit :generate_notification!, if: proc { |record| record.previous_changes.key?('id') || record.previous_changes.key?('responsible_user_id') }
  after_commit :updates_reports_case!, if: proc { |record| record.previous_changes.key?('id') || record.previous_changes.key?('responsible_user_id') }
  after_commit :updates_case_responsible!, if: proc { |record| record.previous_changes.key?('id') || record.previous_changes.key?('responsible_user_id') }

  default_scope -> { order(id: :asc) }

  def my_step
    Version.reify(step_version)
  end

  def executed?
    case_step_data_fields.present?
  end

  private

  def fields_of_step
    field_data = case_step_data_fields

    @sorted_fields = my_step.my_fields.sort do |a, b|
      if a.field_type == 'inventory_field' && b.field_type == 'inventory_field'
        0
      elsif a.field_type == 'inventory_field'
        1
      elsif b.field_type == 'inventory_field'
        -1
      else
        0
      end
    end

    @sorted_fields.each do |field|
      data_field  = field_data.select{ |f| f.field_id == field.id }.try(:first)
      requirement = Hash(field.requirements)

      if data_field.present?
        value   = convert_data(field.field_type, data_field['value'],    data_field)
        minimum = convert_data(field.field_type, requirement['minimum'], data_field)
        maximum = convert_data(field.field_type, requirement['maximum'], data_field)
      else
        value, minimum, maximum = nil
      end

      presence = requirement['presence'] == 'true'
      custom_validations(field, value, minimum, maximum, presence)
    end
  end

  def custom_validations(field, value, minimum, maximum, presence, field_type = nil)
    if presence && value.blank?
      return presence if field.field_type != 'image' && field.field_type != 'attachment'
    end

    field_type = field_type || field.try(:field_type)
    errors_add(field.title, :invalid) if field_type.blank?

    case field_type
    when 'angle'
      errors_add(field.title, :less_than,    count: 360)  if value > 360
      errors_add(field.title, :greater_than, count: -360) if value < -360
    when 'cpf'
      errors_add(field.title, :invalid) if value.present? && !Cpf.new(value).valido?
    when 'cnpj'
      errors_add(field.title, :invalid) if value.present? && !Cnpj.new(value).valido?
    when 'url'
      errors_add(field.title, :invalid) if value !~ URI_FORMAT
    when 'email'
      errors_add(field.title, :invalid) if value !~ EMAIL_FORMAT
    when 'image', 'attachment'
      unless value.blank?
        names = value.map { |d| d['file_name'] }
        errors_add(field.title, :invalid) unless valid_extension_by_filter?(names, field.filter)
      end
    when 'previous_field'
      #nothing to do
    when 'radio'
      value = [value] unless value.is_a?(Array) || value.blank?
      errors_add(field.title, :invalid) if !value.blank? && (value - field.values).present?
    when 'checkbox', 'select'
      value = [value] unless value.is_a?(Array)
      errors_add(field.title, :inclusion) if (value - field.values).present?
    when 'inventory_item'
      if !value.blank? && field.category_inventory_id.size > 0 &&
        field.category_inventory_id[0] != Inventory::Item.select(:inventory_category_id).find(value).first.inventory_category_id
        errors_add(field.title, :inclusion)
      end
    when 'report_item'
      errors_add(field.title, :inclusion) if !value.blank? && field.category_report_id.size > 0 &&
        (Array(value) - Reports::Item.where(reports_category_id: field.category_report_id).pluck(:id)).present?
    end

    if value.is_a?(String) || value.is_a?(Array)
      errors_add(field.title, :greater_than, count: minimum) if minimum.present? && value.size < minimum.to_i
      errors_add(field.title, :less_than,    count: maximum) if maximum.present? && value.size > maximum.to_i
    else
      errors_add(field.title, :greater_than, count: minimum) if minimum.present? && value < minimum
      errors_add(field.title, :less_than,    count: maximum) if maximum.present? && value > maximum
    end
  end

  def valid_extension_by_filter?(value, filter)
    return false if value.blank?
    if filter.present?
      Array.new(value).each do |val|
        file_extension = val.match(/[^\.]+$/).to_s
        return false unless filter.split(',').include? file_extension
      end
    end
    true
  end

  def convert_data(type, value, elem = nil)
    return value if value.blank?
    data_value = value.is_a?(String) ? value.squish! : value

    case type
    when 'string', 'text'
      data_value = data_value.to_s
    when 'integer', 'year', 'month', 'day', 'hour', 'minute', 'second', 'years', 'months', 'days', 'hours', 'minutes', 'seconds'
      data_value = data_value.to_i
    when 'decimal', 'meter', 'centimeter', 'kilometer', 'decimals', 'meters', 'centimeters', 'kilometers'
      data_value = data_value.to_f
    when 'angle'
      data_value = data_value.to_f
    when 'date'
      data_value = data_value.to_date
    when 'time'
      data_value = data_value.to_time
    when 'date_time'
      data_value = data_value.to_datetime
    when 'email'
      data_value = data_value.downcase
    when 'checkbox', 'select'
      data_value = convert_field_data(data_value)
    when 'image'
      data_value = convert_field_data(value)
    when 'attachment'
      data_value = convert_field_data(value)
    when 'previous_field'
      #nothing to do
    when 'inventory_item'
      data_value = convert_field_data(data_value)
    when 'inventory_field'
      inventory_field = Inventory::Field.find(elem.field.origin_field_id)
      data_value      = convert_data(inventory_field.kind, data_value)
    when 'report_item'
      data_value = convert_field_data(data_value).map(&:to_i)
    end
    data_value
  end

  def convert_field_data(data)
    return data unless data.is_a? String
    data =~ /^\[.*\]$/ || data =~ /^\{.*\}$/ ? JSON.parse(data) : data
  end

  def errors_add(name, error_type, *options)
    error = "errors.messages.#{error_type}"
    errors.add(:fields, "#{name} #{I18n.t(error, *options)}")
  end

  def generate_notification!
    notification_params = {
      title: 'Você foi atribuído a uma etapa do caso',
      description: 'Clique mais para ver',
      notificable_id: case_id,
      notificable_type: 'Case'
    }

    Notify.perform_async([responsible_user_id], notification_params)
  end

  def updates_reports_case!
    if responsible_user_id.present?
      Reports::Item.where(case_id: case_id).update_all(assigned_user_id: responsible_user_id)
    end

    true
  end

  def updates_case_responsible!
    if responsible_user_id
      kase.update(responsible_user: responsible_user_id)
    end

    true
  end

  class Entity < Grape::Entity
    def my_step(instance, options)
      options.merge!(display_type: 'full') if simplify_to?(instance.id, options)
      Step::Entity.represent(instance.my_step, options)
    end

    def simplify_to?(case_step_id, options = {})
      Array(options[:simplify_to]).include?(case_step_id)
    end

    def change_options_to_return_fields(key, options = {})
      return options if options[:only].blank?

      fields = options[:only].select do |field|
        field.is_a?(Hash) && field[key].present?
      end

      if fields.any?
        options = options.merge(only: fields.first[key])
      else
        options = options.merge(only: nil)
      end

      options
    end

    expose :id
    expose :step_id
    expose :step_version
    expose :my_step do |instance, options|
      my_step(instance, change_options_to_return_fields(:my_step, options))
    end
    expose :trigger_ids
    expose :responsible_user, using: User::Entity
    expose :responsible_group, using: Group::Entity
    expose :executed?, as: :executed
    expose :updated_at
    expose :created_at
    expose :case_step_data_fields, using: CaseStepDataField::Entity,
           unless: ->(instance, options) { simplify_to? instance.id, options }
    expose :created_by, using: User::Entity,
           unless: ->(instance, options) { simplify_to? instance.id, options }
    expose :updated_by, using: User::Entity,
           unless: ->(instance, options) { simplify_to? instance.id, options }
  end
end
