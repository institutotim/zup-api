module StoreAccessorTypes
  extend ActiveSupport::Concern

  module ClassMethods
    def treat_as_boolean(*attributes)
      attributes.each do |attr|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{attr}
            return super == "true" ? true : false
          end
        METHODS
      end
    end

    def treat_as_array(*attributes)
      attributes.each do |attr|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{attr}
            if super.nil? || (super.is_a?(String) && super == "[]")
              []
            elsif super.is_a?(String)
              super.gsub(/\\"|\\[|\\]/, '').split(',').map(&:to_i)
            elsif super.is_a?(Array)
              super.map(&:to_i)
            elsif
              super
            end
          end

          def #{attr}=(value)
            if value.kind_of?(Array)
              value = value.map(&:to_s).join(',')
            end

            super
          end
        METHODS
      end
    end
  end
end
