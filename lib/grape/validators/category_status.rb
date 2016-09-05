# Validator for CategoryStatus
class CategoryStatus < Grape::Validations::Base
  # Validator classes
  class String
    def self.valid?(content)
      unless content.is_a?(::String)
        return 'must be a String'
      end
    end
  end

  class HexaString
    def self.valid?(content)
      unless content =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i
        return 'must be a Hexadecimal String, format: #112233'
      end
    end
  end

  class Boolean
    def self.valid?(content)
      unless %w(true false).include?(content)
        return 'must be a Boolean (true or false)'
      end
    end
  end

  def validate_param!(attr_name, params)
    required_attributes = {
      title: String,
      color: HexaString,
      initial: Boolean,
      final: Boolean,
      active: Boolean,
      private: Boolean
    }

    errors = []
    params[attr_name].each do |k, status|
      if k.nil? || k.is_a?(Hash)
        errors << Grape::Exceptions::Validation.new(
          params: [@scope.full_name(attr_name)], message: 'must be a valid hash'
        )

        return false
      end

      status = status.symbolize_keys

      required_attributes.each do |name, kind|
        status_params = status[name]

        message = false
        if status_params.nil?
          message = 'must be present'
        else
          message = kind.valid?(status_params)
        end

        if message
          errors << Grape::Exceptions::Validation.new(
            params: [@scope.full_name(name)], message: message
          )
        end
      end
    end unless params[attr_name].nil?

    if errors.any?
      fail Grape::Exceptions::ValidationErrors, errors: errors
    end
  end
end
