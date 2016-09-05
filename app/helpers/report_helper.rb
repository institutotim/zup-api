module ReportHelper
  def image_of_position(report, opts = {})
    latitude, longitude = report.position.y, report.position.x
    icon_url = report.category.marker.default.web.to_s.gsub('https', 'http')

    image_tag "http://maps.googleapis.com/maps/api/staticmap?size=386x386&maptype=roadmap&markers=icon:#{icon_url}|#{latitude},#{longitude}&sensor=false", opts
  end
end
