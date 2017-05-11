module EncodedImageUploadable
  extend ActiveSupport::Concern
  include FileEncodable

  module ClassMethods
    def accepts_encoded_file(*args)
      args.each do |attr_name|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{attr_name}=(new_file)
            if new_file.is_a?(String)
              new_file = encoded_to_file(new_file)
            end

            super
          end
        METHODS
      end
    end

    def expose_multiple_versions(*args)
      args.each do |attr_name|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{attr_name}_structure
            structure = self.fetch_image_versions(self.#{attr_name})
          end
        METHODS
      end
    end

    def accepts_multiple_images_for(param_name)
      class_eval <<-METHODS, __FILE__, __LINE__ + 1
        def update_#{param_name}!(images)
          update_#{param_name}(images)
          self.save!
        end

        def update_#{param_name}(images)
          images = Array(images)

          images.map do |image|
            case image
            when Hash   then convert_hash_to_file('#{param_name}', image)
            when String then convert_string_to_file('#{param_name}', image)
            else
              self.#{param_name}.build(image: image)
            end
          end
        end
      METHODS
    end
  end

  def fetch_image_versions(mounted)
    res = {}

    if mounted.versions.empty?
      res = mounted.to_s
    else
      mounted.versions.each do |name, v|
        res[name] = fetch_image_versions(v)
      end
    end

    res
  end

  private

  def convert_hash_to_file(association_name, options = {})
    options.try(:symbolize_keys!)

    association = public_send(association_name)

    if options[:head]
      association.build(image: options)
    else
      file_name = options.delete(:file_name)
      content   = options.delete(:file) || options.delete(:content)
      id        = options.delete(:id)

      record = association.find(id) if id

      if record && options[:destroy]
        record.destroy
      else
        record ||= association.build

        record.image = encoded_to_file(content, file_name) if content

        options.each do |key, value|
          if record.respond_to?("#{key}=")
            record.public_send("#{key}=", value)
          end
        end

        record.save unless record.new_record?
        record
      end
    end
  end

  def convert_string_to_file(association_name, image)
    temp_file = encoded_to_file(image)
    public_send(association_name).build(image: temp_file)
  end
end
