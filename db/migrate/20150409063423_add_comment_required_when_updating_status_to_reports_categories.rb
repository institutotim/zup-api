class AddCommentRequiredWhenUpdatingStatusToReportsCategories < ActiveRecord::Migration
  def up
    add_column :reports_categories, :comment_required_when_updating_status, :boolean, default: false
    change_column_default :reports_categories, :comment_required_when_forwarding, false
  end

  def down
    remove_column :reports_categories, :comment_required_when_updating_status
    change_column_default :reports_categories, :comment_required_when_forwarding, nil
  end
end
