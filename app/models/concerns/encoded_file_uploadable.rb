module EncodedFileUploadable
  extend ActiveSupport::Concern

  # Get encoded file and add to a temp
  # encoded files
  def encoded_to_file(encoded_file, file_name = nil)
    extension = file_name ? ".#{file_name.match(/[^\.]+$/)}" : ''
    temp_file = Tempfile.new([SecureRandom.hex(3), extension])
    temp_file.binmode
    temp_file.write(Base64.decode64(encoded_file))
    temp_file.close
    temp_file
  end

  module ClassMethods
    def accepts_encoded_file(*args)
      args.each do |attr_name|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{attr_name}=(new_file)
            if new_file.is_a?(String)
              new_file = encoded_to_file(new_file)
            elsif new_file.is_a?(Hash)
              file_name = new_file['file_name']
              content   = new_file['content']

              if file_name && content
                new_file = encoded_to_file(content, file_name)
              end
            end

            super
          end
        METHODS
      end
    end

    def accepts_multiple_files_for(param_name)
      class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def update_#{param_name}!(files)
            update_#{param_name}(files)
            self.save!
          end

          def update_#{param_name}(files)
            files.each do |file|
              file_name = file.is_a?(Hash) ? file['file_name'] : nil
              content   = file.is_a?(Hash) ? file['content'] : nil
              if file.is_a?(Hash) && file_name && content
                temp_file = encoded_to_file(content, file_name)
                self.#{param_name}.build(attachment: temp_file, file_name: file_name)
                temp_file.close

                # If the file already exists and you are
                # changing it.
              elsif file.is_a?(Hash) && file['id'].present?
                if file['file'].is_a?(String)
                  temp_file = encoded_to_file(file['file'])
                  self.#{param_name}.find(file['id']).update(attachment: temp_file)
                  temp_file.close
                else
                  self.#{param_name}.find(file['id']).update(attachment: file['file'])
                end
              else
                self.#{param_name}.build(attachment: file)
              end
            end
          end
      METHODS
    end
  end
end
