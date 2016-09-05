module Reports
  class ChangeItemCategory
    attr_reader :item, :new_category, :new_status, :user, :new_setting

    def initialize(item, new_category, new_status, user = nil)
      @item = item
      @new_category = new_category
      @new_status = new_status
      @new_setting = new_category.settings.find_by(namespace_id: item.namespace_id)
      @user = user
    end

    def process!
      old_category = item.category

      if old_category.id != new_category.id && item.update(category: new_category)
        update_status!

        # Forward to default group
        if new_setting.default_solver_group || new_setting.perimeters?
          Reports::ForwardToGroup.new(item, user).forward_without_comment!(
            new_setting.default_solver_group
          )
        else
          item.update(assigned_group: nil, assigned_user: nil)
        end

        create_history_entry(old_category)
      elsif old_category.id == new_category.id
        update_status!
      end
    end

    private

    def update_status!
      Reports::UpdateItemStatus.new(item, user).update_status!(new_status)
    end

    def create_history_entry(old_category)
      message = "O relato foi movido da categoria '#{old_category.title}' para '#{new_category.title}'"

      service = Reports::CreateHistoryEntry.new(item, user)

      service.create(
        'category', message,
        old: old_category.entity(only: [:id, :title]),
        new: new_category.entity(only: [:id, :title])
      )
    end
  end
end
