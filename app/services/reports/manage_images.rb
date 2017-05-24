class Reports::ManageImages
  include FileEncodable

  attr_reader :user, :item, :history_engine

  def initialize(user, item)
    @user = user
    @item = item
    @history_engine = Reports::CreateHistoryEntry.new(item, user)
  end

  def create!(images)
    Reports::Image.transaction do
      new_images = item.update_images(images)
      item.save!

      create_history_entry(new_images)
    end
  end

  def update!(images)
    Reports::Image.transaction do
      new_images = item.update_images(images)
      create_history_entry(new_images, :update)
    end
  end

  private

  def create_history_entry(images, action = :create)
    if action == :create
      message = 'Adicionada imagem'
      kind = 'add_image'
    end

    message ||= 'Atualizada imagem'
    kind ||= 'update_image'

    images.each do |image|
      history_engine.create(
        kind,
        "#{message}: #{image.filename}",
        new: image.entity(only: [:url, :filename])
      )
    end
  end
end
