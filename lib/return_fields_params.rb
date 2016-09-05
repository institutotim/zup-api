class ReturnFieldsParams
  attr :param

  def initialize(param)
    @param = param
  end

  def to_array
    return nil unless param

    structure = {}

    param.split(',').each do |attr_name|
      if attr_name['.']
        attrs = attr_name.split('.')

        attr_data = attrs.reverse.inject(true) do |data, attr|
          data = { attr.to_sym => data }
          data
        end

        structure = structure.deep_merge(attr_data)
      else
        structure[attr_name.to_sym] = true
      end
    end

    extract_structure(structure)
  end

  private

  def extract_structure(data)
    array = []

    data.each do |attr, value|
      if value.is_a?(Hash)
        array << {
          attr => extract_structure(value)
        }
      else
        array << attr
      end
    end

    array
  end
end
