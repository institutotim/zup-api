class CaseStepDataField < ActiveRecord::Base
  cattr_accessor :correct_case_step, :inventory_item, :user

  include EncodedImageUploadable
  include EncodedFileUploadable

  has_many :case_step_data_images, autosave: true
  has_many :case_step_data_attachments, autosave: true

  accepts_multiple_images_for :case_step_data_images
  accepts_multiple_files_for :case_step_data_attachments

  belongs_to :field
  belongs_to :case_step, inverse_of: :case_step_data_fields
  has_one :case, through: :case_step, source: :kase

  default_scope { order(:field_id) }

  validates_presence_of :field_id
  validates_presence_of :case_step

  def value=(value)
    if field.field_type == 'image'
      if value.blank? && self.value
        return super(self.value)
      end

      images_to_remove = value.select { |v| v[:destroy] }
      delete_marked_images(images_to_remove) if images_to_remove.size > 0
      current_value = value.reject { |v| v[:destroy] }
      update_case_step_data_images(value.reject { |v| v[:destroy] })
      super(current_value.map { |v| v['file_name'] }.to_s)
    elsif field.field_type == 'attachment'
      if value.blank? && self.value
        return super(self.value)
      end

      files_to_remove = value.select { |v| v[:destroy] }
      delete_marked_files(files_to_remove) if files_to_remove.size > 0
      current_value = value.reject { |v| v[:destroy] }
      update_case_step_data_attachments(current_value)
      super(current_value.map { |v| v['file_name'] }.to_s)
    elsif field.field_type == 'inventory_field'
      fail 'Inventory Item needed to be updated from a case' if inventory_item.blank?
      inventory_field = Inventory::Field.find(field.origin_field_id)

      # This needs to happen because `case_step_id` and `case_step`
      # is null for some lovely Rails reason
      kase_step = case_step ? case_step : correct_case_step

      selector_field_data = kase_step.case_step_data_fields.select { |csdf| csdf.field_id == field.field_id }.first
      return unless selector_field_data.value

      representer = inventory_item.represented_data(user)
      representer.send(:"#{inventory_field.title}=", value)

      if value.is_a?(Hash) || value.is_a?(Array)
        super(value.to_json)
      else
        super(value.to_s)
      end
    else
      super(value.to_s)
    end
  end

  def delete_marked_files(file_entries)
    file_entries_ids = file_entries.map { |f| f[:id] }
    case_step_data_attachments.where(id: file_entries_ids).delete_all
  end

  def delete_marked_images(image_entries)
    image_entries_ids = image_entries.map { |f| f[:id] }
    case_step_data_images.where(id: image_entries_ids).delete_all
  end

  def report_items
    unless value.nil? || value.blank? || field.nil? || field.field_type != 'report_item'
      item_ids = JSON.parse(value)
      return [] if item_ids.size < 1
      items = Reports::Item.where(id: item_ids).select([:id, :protocol, :reports_category_id])
      items.map do |item|
        category = Reports::Category.select([:id, :icon, :title]).find(item.reports_category_id)
        { id: item.id, protocol: item.protocol, category: { id: item.reports_category_id, icon: category.icon.default.web.active.to_s, title: category.title } }
      end
    end
  end

  def inventory_items
    unless value.nil? || value.blank? || field.nil? || field.field_type != 'inventory_item'
      item_ids = JSON.parse(value)
      return [] if item_ids.size < 1
      items = Inventory::Item.where(id: item_ids).select([:id, :inventory_category_id])
      items.map do |item|
        { id: item.id, title: item.data_value_as_title, category: { title: item.category.title, icon: item.category.icon.default.web.active.to_s } }
      end
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :field, using: Field::Entity
    expose :value do |data_field|
      if data_field.value == '[nil]'
        []
      elsif data_field.value
        data_field.value.match(/^\[.*\]$/) || data_field.value.match(/^\{.*\}$/) ? JSON.parse(data_field.value) : data_field.value
      end
    end
    expose :case_step_data_images, using: CaseStepDataImage::Entity
    expose :case_step_data_attachments, using: CaseStepDataAttachment::Entity
    expose :report_items
    expose :inventory_items
  end
end
