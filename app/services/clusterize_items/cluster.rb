module ClusterizeItems
  class Cluster
    include ActiveModel::Model

    attr_accessor :items_ids, :category_id, :count, :center, :categories_ids

    def position
      [center.y, center.x]
    end

    class Entity < Grape::Entity
      expose :items_ids
      expose :position
      expose :category_id
      expose :count
      expose :categories_ids, if: -> (instance, _options) do
        !instance.categories_ids.nil?
      end
    end
  end
end
