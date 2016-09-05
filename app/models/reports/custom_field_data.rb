class Reports::CustomFieldData < Reports::Base
  self.table_name = 'reports_custom_field_data'
  belongs_to :custom_field, class_name: 'Reports::CustomField', foreign_key: 'reports_custom_field_id'
  belongs_to :item, class_name: 'Reports::Item', foreign_key: 'reports_item_id'

  validates :custom_field, presence: true
  validates :item, presence: true

  class Entity < Grape::Entity
    expose :reports_custom_field_id, as: :id
    expose :value
  end
end
