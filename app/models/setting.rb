class Setting < ActiveRecord::Base
  enum kind: [:string, :array, :json]

  def value=(value)
    if value.is_a?(Array)
      if value.first.is_a?(Hash)
        self.kind = :json
        value = value.map { |v| v.to_json }
      else
        self.kind = :array
      end
    elsif value.is_a?(Hash)
      self.kind = :json
      value = [value.to_json]
    else
      self.kind = :string
      value = [value]
    end

    super
  end

  def value
    if string?
      super.first
    elsif json?
      if super.size > 1
        super.map { |v| Oj.load(v) }
      else
        Oj.load(super.first)
      end
    else
      super
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :name
    expose :value
  end
end
