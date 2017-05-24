module Reports::Images
  class API < Base::API
    desc 'List images of the report'
    get '/items/:reports_item_id/images' do
      authenticate!

      report = Reports::Item.find(safe_params[:reports_item_id])
      validate_permission!(:view, report)

      images =
        if user_permissions.can?(:view_private, report) ||
            user_permissions.can?(:edit, object)

          report.images
        else
          report.images.visible
        end

      {
        images: Reports::Image::Entity.represent(images)
      }
    end

    desc 'Create images for report'
    params do
      requires :images, type: Array,
        desc: 'An array of images(post data or encoded on base64) for this report.'
    end
    post '/items/:reports_item_id/images' do
      authenticate!

      report = Reports::Item.find(safe_params[:reports_item_id])
      images = params[:images]

      validate_permission!(:edit, report)

      images = Reports::ManageImages.new(current_user, report).create!(images)

      {
        images: Reports::Image::Entity.represent(images)
      }
    end

    desc 'Update images for report'
    params do
      requires :images, type: Array,
        desc: 'An array of images(post data or encoded on base64) for this report.'
    end
    put '/items/:reports_item_id/images' do
      authenticate!

      report = Reports::Item.find(safe_params[:reports_item_id])
      images = params[:images]

      validate_permission!(:edit, report)

      images = Reports::ManageImages.new(current_user, report).update!(images)

      {
        images: Reports::Image::Entity.represent(images)
      }
    end

    desc 'Delete the image'
    delete '/items/:reports_item_id/images/:id' do
      authenticate!

      report = Reports::Item.find(safe_params[:reports_item_id])

      validate_permission!(:edit, report)

      image = report.images.find(safe_params[:id])

      if image.destroy
        Reports::CreateHistoryEntry.new(report, current_user).create(
          'remove_image',
          "Removida imagem: #{image.filename}",
          old: image.entity(only: [:filename])
        )

        status 204
      else
        status 422
      end
    end
  end
end
