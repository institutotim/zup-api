class CreateReportsFeedbacks < ActiveRecord::Migration
  def change
    create_table :reports_feedbacks do |t|
      t.belongs_to :reports_item, index: true
      t.belongs_to :user, index: true
      t.string :kind, null: false
      t.text :content

      t.timestamps
    end
  end
end
