module ImageHelper
  def encoded_image(image)
    image_path = "#{Application.config.root}/spec/fixtures/images/#{image}"
    file = fixture_file_upload(image_path).read

    Base64.encode64(file)
  end
end
