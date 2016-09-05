module BoundaryValidation
  extend ActiveSupport::Concern

  def check_position_within_boundary
    if CityShape.validation_enabled?
      attr = self.class.instance_variable_get('@attr_check_against_boundary')
      position = send(attr)

      return true if position.nil?

      unless CityShape.contains?(position.y, position.x)
        errors.add(:position, 'está fora do limite configurado da cidade')
      end
    end
  end

  module ClassMethods
    def validate_in_boundary(attr)
      @attr_check_against_boundary = attr
      validate :check_position_within_boundary
    end
  end
end
