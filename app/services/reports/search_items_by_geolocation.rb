module Reports
  class SearchItemsByGeolocation
    attr_reader :scope, :position_params, :address

    def initialize(scope, position_params, address)
      @scope = scope
      @position_params = normalize_params(position_params)
      @address = address
    end

    def scope_with_filters
      # Build SQL statement
      @scope = scope.where(
        *build_sql_statement(position_params)
      )

      scope
    end

    private

    def build_sql_statement(position_hash)
      statement = ''

      position_hash.each do |_index, p|
        latlon = "POINT(#{p[:longitude].to_f} #{p[:latitude].to_f})"

        # Distance in meters
        distance = p[:distance].to_i

        unless statement.blank?
          statement += ' OR '
        end

        statement += <<-SQL
          ST_DWithin(
            ST_GeomFromText('#{latlon}', 4326)::geography,
            reports_items.position, #{distance}
          )
        SQL
      end

      if address
        statement += <<-SQL
          OR reports_items.address ILIKE ?
        SQL

        [statement, "%#{address}%"]
      else
        [statement]
      end
    end

    def normalize_params(params)
      if params.key?(:latitude)
        { 0 => params }
      else
        params
      end
    end
  end
end
