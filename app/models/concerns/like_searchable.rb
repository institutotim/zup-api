module LikeSearchable
  extend ActiveSupport::Concern

  module ClassMethods
    def like_search(fields = {})
      query = ''
      values = []
      fields.each do |field, value|
        unless value.blank?
          unless query.blank?
            query += ' OR '
          end

          # If it has a dot,
          # it's already expliciting a table
          unless field['.']
            field = "#{table_name}.#{field}"
          end

          query += "UNACCENT(CAST(#{field} as varchar)) ILIKE UNACCENT(?)"
          values << "%#{value}%"
        end
      end

      relation = where(query, *values)
      relation
    end
  end
end
