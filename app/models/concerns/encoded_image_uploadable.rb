module EncodedImageUploadable
  extend ActiveSupport::Concern

  # Get encoded file and add to a temp
  # encoded images
  def encoded_to_file(encoded_image, extension = 'png')
    temp_file = Tempfile.new([SecureRandom.hex(3), ".#{extension}"], "#{Application.config.root}/tmp")
    temp_file.binmode
    temp_file.write(Base64.decode64(encoded_image))
    temp_file.close
    temp_file
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
            images.each do |image|
              if image.is_a?(Hash)
                file_name = image['file_name']
                content   = image['content']
                title     = image['title']
              end

              if image.is_a? String
                temp_file = encoded_to_file(image)
                self.#{param_name}.build(image: temp_file)
                temp_file.close

              elsif image.is_a?(Hash) && file_name && content
                extension = file_name ? file_name.match(/[^\.]+$/).to_s : nil
                temp_file = encoded_to_file(content, extension)

                record = self.#{param_name}.build(image: temp_file)
                record.title = title if record.respond_to?(:title)

                temp_file.close

                # If the image already exists and you are
                # changing it.
              elsif image.is_a?(Hash) && image['id'].present?
                if image['file'].is_a?(String)
                  temp_file = encoded_to_file(image['file'])

                  record = self.#{param_name}.find(image['id'])
                  record.image = temp_file
                  record.title = title if record.respond_to?(:title)
                  record.save

                  temp_file.close
                else
                  record = self.#{param_name}.find(image['id'])
                  record.image = image['file']
                  record.title = title if record.respond_to?(:title)
                  record.save
                end
              else
                self.#{param_name}.build(image: image)
              end
            end
          end
      METHODS
    end
  end
end
