module Reports
  class ItemCacheControl
    attr_reader :reports

    def initialize(reports)
      @reports = reports
    end

    def garner_cache_key
      #reports.map(&:id).inject(:+)
      nil
    end
  end
end
