module Reports
  class FlagItemAsOffensive
    class UserAlreadyReported < StandardError; end
    class UserReachedReportLimit < StandardError; end

    MAXIMUM_REPORTS_BY_HOUR_PER_USER = ENV['MAXIMUM_REPORTS_PER_USER_BY_HOUR'] || 20
    MINIMUM_FLAGS_TO_MARK = ENV['MINIMUM_FLAGS_TO_MARK_REPORT_OFFENSIVE'] || 10

    attr_reader :user, :item

    def initialize(user, item)
      @user = user
      @item = item
    end

    def flag!
      validate_user_report_for_item!
      validate_user_report_limit!

      Reports::OffensiveFlag.create!(
        user: user,
        item: item
      )

      mark_item_as_offensive!
    end

    def unflag!
      item.offensive_flags.destroy_all
      item.update!(offensive: false)
    end

    def mark_item_as_offensive!
      if item.offensive_flags.count >= MINIMUM_FLAGS_TO_MARK
        item.update!(offensive: true)
      end
    end

    private

    def validate_user_report_limit!
      if Reports::OffensiveFlag.by_user(user).in_last_hour.count >= \
            MAXIMUM_REPORTS_BY_HOUR_PER_USER
        fail UserReachedReportLimit
      end
    end

    def validate_user_report_for_item!
      if Reports::OffensiveFlag.for(user, item)
        fail UserAlreadyReported
      end
    end
  end
end
