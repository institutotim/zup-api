module Reports
  class ValidateVersion
    class VersionMismatch < StandardError; end

    attr_reader :item, :version

    def initialize(item, version)
      @item = item
      @version = version
    end

    def validate!
      item.with_lock do
        fail VersionMismatch unless item.version == version
      end

      true
    end
  end
end
