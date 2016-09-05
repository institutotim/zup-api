module Reports
  class CreateHistoryEntry
    attr_reader :item, :user, :kind, :action

    def initialize(item, user = nil)
      @item = item
      @user = user
    end

    def create(kind, action, given_changes = {})
      entry = build_object(kind, action, given_changes)
      entry.save!
    rescue ActiveRecord::RecordInvalid => e
      ErrorHandler.capture_exception(e)
    end

    def detect_changes_and_create!(attributes)
      return {} unless item.previous_changes.any?

      item.previous_changes.each do |attribute, (old_value, new_value)|
        if attributes.include?(attribute.to_sym)
          changes = {
            old: old_value,
            new: new_value
          }

          build_object(attribute, 'Alterou atributo', changes).save!
        end
      end
    end

    private

    def build_object(kind, action, changes)
      entry = Reports::ItemHistory.new(
        item: item,
        user: user,
        kind: kind,
        action: action
      )

      entry.saved_changes = changes if changes.any?
      entry
    end
  end
end
