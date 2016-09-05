module Reports
  class GetCommentsForUser
    attr_reader :item, :user

    def initialize(item, user = nil)
      @item, @user = item, user
    end

    def comments
      return [] if item.comments.count == 0
      comments = item.comments.with_visibility(visibility)
    end

    private

    def visibility
      user_permissions = UserAbility.for_user(user)

      if user_permissions.can?(:view_private, item) || user_permissions.can?(:edit, item)
        Reports::Comment::INTERNAL
      elsif user && (user.id == item.user_id || user_permissions.can?(:edit, item))
        Reports::Comment::PRIVATE
      else
        Reports::Comment::PUBLIC
      end
    end
  end
end
