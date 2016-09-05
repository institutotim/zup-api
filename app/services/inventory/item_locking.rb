module Inventory
  class ItemLocking
    attr_reader :item, :user

    def initialize(item, user = nil)
      @item = item
      @user = user
    end

    # Locks the category
    def lock!
      fail 'Need user' unless user

      item.locked = true
      item.locked_at = Time.now
      item.locker = user

      item.save!(validate: false)
    end

    # Unlocks the category
    def unlock!
      item.locked = false
      item.save!(validate: false)
    end

    def unlock_if_expired!
      if item.locked_at <= 1.minute.ago
        unlock!
      end
    end
  end
end
