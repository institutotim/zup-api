class Reports::CategoryCustomField < Reports::Base
  belongs_to :category, class_name: 'Reports::Category', foreign_key: 'reports_category_id'
  belongs_to :custom_field, class_name: 'Reports::CustomField', foreign_key: 'reports_custom_field_id'
end
