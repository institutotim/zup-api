module FileEncodingHelper
  def encode64(file_path)
    full_file_path = "#{Application.config.root}/spec/fixtures/#{file_path}"
    file = fixture_file_upload(full_file_path).read

    Base64.encode64(file)
  end
end
