module FileEncodable
  def encoded_to_file(encoded_file, file_name = '')
    extension = File.extname(file_name.to_s)
    extension = '.png' if extension.blank?

    write_tempfile(encoded_file, extension)
  end

  protected

  def decode(encoded_file)
    Base64.decode64(encoded_file)
  end

  def write_tempfile(encoded_file, extension)
    Tempfile.new([SecureRandom.hex(3), extension]).tap do |temp_file|
      temp_file.binmode
      temp_file.write(decode(encoded_file))
      temp_file.close
    end
  end
end
