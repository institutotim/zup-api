class CreateReportsFeedbackImages < ActiveRecord::Migration
  def change
    create_table :reports_feedback_images do |t|
      t.belongs_to :reports_feedback, index: true
      t.string :image

      t.timestamps
    end
  end
end
