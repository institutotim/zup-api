class Chart < ActiveRecord::Base
  belongs_to :business_report

  # All available metrics
  enum metric: [
    # Qualitative
    :'total-reports-by-category',
    :'total-reports-by-status',
    :'total-reports-overdue-by-category',
    :'total-reports-overdue-by-category-per-day',
    :'total-reports-assigned-by-category',
    :'total-reports-assigned-by-group',
    :'total-reports-unassigned-to-user',

    # Quantitative
    :'average-resolution-time-by-category',
    :'average-resolution-time-by-group',
    :'average-overdue-time-by-category',
    :'average-overdue-time-by-group'
  ]

  enum chart_type: [:pie, :line, :bar, :area]

  validates :title, presence: true
  validates :metric, presence: true
  validates :chart_type, presence: true
  validates :begin_date, presence: true
  validates :end_date, presence: true

  validate :date_validity
  before_validation :set_dates_from_business_reports

  default_scope -> { order(id: :asc) }

  def processed?
    !data.nil?
  end

  def categories
    Reports::Category.where(id: categories_ids)
  end

  class Entity < Grape::Entity
    expose :id
    expose :metric
    expose :chart_type
    expose :title
    expose :description
    expose :data
    expose :processed?, as: :processed
    expose :categories, using: Reports::Category::Entity
    expose :begin_date
    expose :end_date
  end

  private

  def date_validity
    if (begin_date.present? && end_date.present?) && begin_date > end_date
      errors.add(:begin_date, I18n.t(:'errors.messages.end_date_lower_than_begin_date'))
    end
  end

  def set_dates_from_business_reports
    self.begin_date = business_report.begin_date if begin_date.nil?
    self.end_date = business_report.end_date if end_date.nil?

    true
  end
end
