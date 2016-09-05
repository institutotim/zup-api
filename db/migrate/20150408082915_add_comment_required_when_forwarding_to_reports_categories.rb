class AddCommentRequiredWhenForwardingToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :comment_required_when_forwarding, :boolean
  end
end
