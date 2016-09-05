module ClusterizeItems
  class Base
    attr_reader :scope, :zoom, :klass, :category_attribute, :item_type

    def initialize(scope, zoom = '15', opts = {})
      @scope = scope
      @zoom = zoom
      @klass = opts[:klass]
      @category_attribute = opts[:category_attribute]
      @item_type = opts[:item_type]
    end

    def results
      entities = nil

      with_large_work_mem do
        entities = klass.find_by_sql(
          build_sql
        )
      end

      data = {
        clusters: [],
        item_type => [],
        total: 0
      }
      items_ids = []

      entities.each do |entity|
        if entity.number_of_items > 1
          cluster = ClusterizeItems::Cluster.new(
            center: entity.center,
            count: entity.number_of_items,
            items_ids: entity.items_ids
          )

          cluster.category_id = entity.send(category_attribute.to_sym) if entity.respond_to?(category_attribute.to_sym)
          cluster.categories_ids = entity.categories_ids if entity.respond_to?(:categories_ids)

          data[:clusters] << cluster
          data[:total] += entity.number_of_items
        else
          items_ids << entity.items_ids[0]
          data[:total] += 1
        end
      end

      data[item_type] = klass.where(id: items_ids)
                          .includes(:user)
      data
    end

    private

    def build_sql
      <<-SQL
        SELECT #{select_statement}
        FROM (#{changed_scope.to_sql}) as scope
        GROUP BY #{group_by_statement}
      SQL
    end

    def group_by_statement
      if zoom.to_i > 12
        "#{category_attribute}, grid"
      else
        'grid'
      end
    end

    def select_statement
      statement = 'array_agg(scope.id) as items_ids, ST_Centroid(ST_Collect(ST_SetSRID(scope.position, 4326))) AS center, COUNT(*) AS number_of_items'

      if zoom.to_i > 12
        statement = "#{statement}, #{category_attribute}"
      else
        statement = "#{statement}, array_agg(scope.#{category_attribute}) as categories_ids"
      end

      statement
    end

    def zoom_to_size
      @zoom_map ||= {
        '20' => 0,
        '19' => 0,
        '18' => 0,
        '17' => 0.0005,
        '16' => 0.001,
        '15' => 0.0025,
        '14' => 0.005,
        '13' => 0.01,
        '12' => 0.025,
        '11' => 0.1,
        '10' => 0.5,
        '9'  => 0.75,
        '8'  => 2,
        '7'  => 2.5,
        '6'  => 2.75,
        '5'  => 3,
        '4'  => 4,
        '3'  => 5,
        '2'  => 50,
        '1'  => 100,
        '0'  => 1000
      }

      @zoom_map[zoom.to_s]
    end

    def changed_scope
      @scope.distinct.select(
        "#{klass.table_name}.*, ST_SnapToGrid( ST_SetSRID(#{klass.table_name}.position, 4326), #{zoom_to_size}) as grid"
      ).order(id: :asc)
    end

    def with_large_work_mem
      klass.transaction do
        klass.connection.execute("SET work_mem='10MB';")
        yield
        klass.connection.execute("SET work_mem='1MB';")
      end
    end
  end
end
