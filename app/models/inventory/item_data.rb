class Inventory::ItemData < Inventory::Base
  belongs_to :item, class_name: 'Inventory::Item', foreign_key: 'inventory_item_id'
  belongs_to :field, class_name: 'Inventory::Field', foreign_key: 'inventory_field_id'

  has_many :images, class_name: 'Inventory::ItemDataImage', foreign_key: 'inventory_item_data_id', autosave: true
  has_many :attachments, class_name: 'Inventory::ItemDataAttachment', foreign_key: 'inventory_item_data_id', autosave: true

  default_scope -> { order('inventory_item_data.id ASC') }

  # Location related fields
  scope :location, -> { joins(:field).where('inventory_fields.location' => true) }

  # Override the setter to allow
  # accepting images and string values
  def content=(content)
    if field.kind == 'images'
      build_images_for(content)
    elsif field.kind == 'attachments'
      build_attachments_for(content)
    elsif field.use_options?
      content = [content] unless content.is_a?(Array)
      self.selected_options_ids = content.map(&:to_i)
    elsif !content.is_a?(Array)
      write_attribute(:content, [content])
    else
      super
    end
  end

  def content
    if field && field.kind == 'images'
      Inventory::ItemDataImage::Entity.represent(images)
    elsif field && field.kind == 'attachments'
      Inventory::ItemDataAttachment::Entity.represent(attachments)
    elsif field && field.use_options?
      if selected_options.blank?
        nil
      else
        selected_options.map(&:id)
      end
    elsif !read_attribute(:content).nil? && (field && field.content_type != Array)
      super.first
    else
      super
    end
  end

  # Field options reference (from `inventory_field_option_ids` column)
  # If we use this kind of association using
  # PG arrays, we should put this in a concern.
  def selected_options
    if inventory_field_option_ids.blank?
      []
    else
      Inventory::FieldOption.where(id: inventory_field_option_ids).includes(:field)
    end
  end

  def selected_options=(field_options)
    if field_options.is_a?(Array)
      self.inventory_field_option_ids = field_options.map(&:id)
    end
  end

  def selected_options_ids=(field_options_ids)
    if field_options_ids.is_a?(Array)
      self.inventory_field_option_ids = field_options_ids
    end
  end

  def use_options?
    field.use_options?
  end

  # Returns the content in the right type
  def converted_content
    return content unless field

    # Put this on a dedicated class/module
    # It is used on the ItemDataRepresenter as well
    convertors = {
      Fixnum => proc do |c|
        c.to_i
      end,
      Float => proc do |c|
        c.to_f
      end
    }

    convertor = convertors[field.content_type]

    if convertor && !content.nil?
      convertor.call(content)
    else
      content
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :field, using: Inventory::Field::Entity
    expose :inventory_field_id
    expose :converted_content, as: :content
    expose :selected_options, using: Inventory::FieldOption::Entity
  end

  private

  def build_images_for(images)
    return if images.nil? || !images.is_a?(Array)

    images.each do |image_data|
      if image_data['destroy'] && image_data['id']
        self.images.find(image_data['id']).destroy
      else
        begin
          temp_file = Tempfile.new([SecureRandom.hex(3), '.jpg'])
          temp_file.binmode
          temp_file.write(Base64.decode64(image_data['content']))
          temp_file.close

          self.images.build(image: temp_file)
        ensure
          temp_file.unlink
        end
      end
    end
  end

  # This is pretty much identical to the method above
  # TODO: Refactorate this
  def build_attachments_for(attachments)
    return if attachments.nil? || !attachments.is_a?(Array)

    attachments.each do |attachment_data|
      if attachment_data['destroy'] && attachment_data['id']
        self.attachments.find(attachment_data['id']).destroy
      else
        begin
          file_name = attachment_data['file_name']
          extension = file_name ? ".#{file_name.match(/[^\.]+$/)}" : ''
          temp_attachment = Tempfile.new([SecureRandom.hex(3), extension])
          temp_attachment.binmode
          temp_attachment.write(Base64.decode64(attachment_data['content']))
          temp_attachment.close

          self.attachments.build(attachment: temp_attachment)
        ensure
          temp_attachment.unlink
        end
      end
    end
  end
end
