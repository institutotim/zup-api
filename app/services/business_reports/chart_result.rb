module BusinessReports
  class ChartResult
    attr_reader :data_array, :subtitles

    # Both params are an array
    def initialize(subtitles, data_array)
      @subtitles  = subtitles
      @data_array = data_array
    end

    def serialize
      @serializable_data ||= Entity.new(self).serializable_hash
    end

    class Entity < Grape::Entity
      expose :subtitles
      expose :data_array, as: :content
    end
  end
end
