module Reports
  class NotificationLayoutParser
    attr_reader :notification

    PLACEHOLDERS = {
      'user_name' => lambda do |item, _notification|
        item.user.name
      end,
      'user_address' => lambda do |item, _notification|
        item.user.address
      end,
      'user_phone' => lambda do |item, _notification|
        item.user.phone
      end,
      'user_document' => lambda do |item, _notification|
        item.user.document
      end,
      'item_protocol' => lambda do |item, _notification|
        item.protocol
      end,
      'item_images' => lambda do |item, _notification|
        images = item.images.reduce('<div class="report-image">') do |acc, img|
          %[#{acc}<img class="report-image" src="#{img.image_url(:high)}" />]
        end

        "#{images}</div>"
      end,
      'item_address' => lambda do |item, _notification|
        item.full_address
      end,
      'item_reference' => lambda do |item, _notification|
        item.reference
      end,
      'item_description' => lambda do |item, _notification|
        item.description
      end,
      'item_created_at' => lambda do |item, _notification|
        I18n.l(item.created_at, format: '%d/%m/%Y')
      end,
      'item_status_title' => lambda do |item, _notification|
        item.status.title
      end,
      'category_title' => lambda do |item, _notification|
        item.category.title
      end,
      'notification_created_at' => lambda do |_item, notification|
        I18n.l(notification.created_at, format: '%d/%m/%Y')
      end,
      'notification_overdue_at' => lambda do |_item, notification|
        I18n.l(notification.overdue_at, format: '%d/%m/%Y') if notification.overdue_at
      end
    }

    def initialize(notification)
      @notification = notification
    end

    def parsed_html
      layout = notification.notification_type.layout
      item = notification.item

      if layout
        PLACEHOLDERS.each do |key, func|
          regexp_key = /\[\[#{Regexp.quote(key)}\]\]/i

          if layout[regexp_key]
            layout = layout.gsub(regexp_key, func.call(item, notification).to_s)
          end
        end
      end

      layout
    end
  end
end
