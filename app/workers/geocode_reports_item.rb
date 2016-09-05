class GeocodeReportsItem
  include Sidekiq::Worker

  def perform(reports_item_id)
    item = Reports::Item.find_by(id: reports_item_id)
    logger.info "Looking for item ##{reports_item_id}"

    if item
      logger.info "Found item ##{reports_item_id}. Geocoding..."
      begin
        Reports::GeocodeItem.new(item).find_position_and_update!
        item.reload

        if item.position
          logger.info "Item geocoded successfully ##{reports_item_id}."
        else
          logger.info "Could'nt geocode ##{reports_item_id}"
        end
      rescue Geocoder::OverQueryLimitError => e
        logger.info 'Query limit found, rescheduling to 24 hours from now'
        GeocodeReportsItem.perform_in(24.hours, item.id)
      end
    end
  end
end
