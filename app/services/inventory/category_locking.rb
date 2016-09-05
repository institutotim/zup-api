module Inventory
  class CategoryLocking
    attr_reader :category, :user

    def initialize(category, user = nil)
      @category = category
      @user = user
    end

    # Locks the category
    def lock!
      fail 'Need user' unless user

      category.locked = true
      category.locked_at = Time.now
      category.locker = user

      category.save!
    end

    # Unlocks the category
    def unlock!
      category.locked = false
      category.save!
    end

    def unlock_if_expired!
      if category.locked_at <= 1.minute.ago
        unlock!
      end
    end
  end
end
