class Version < PaperTrail::Version
  def self.reify_last_version(resource)
    resource.versions.last.try(:reify)
  end

  def self.reify(id)
    find(id).reify
  end

  def self.where(class_name, ids = {}, conditions = {})
    # maked this way to return in sequence
    ids.map do |id, version|
      resource = version.present? && !conditions.include?(:draft) ? reify(version) : class_name.constantize.find_by(id: id)
      invalid  = conditions.map { |key, value| resource.try(key) == value }.include? false
      invalid ? nil : resource
    end.compact
  end

  def self.build!(resource, override = false)
    whodunnit    = resource.try(:user) || resource.try(:updated_by) || resource.try(:created_by)
    object_attrs = resource.send('object_attrs_for_paper_trail', resource)
    object_value = resource.class.paper_trail_version_class.object_col_is_json? ?
                     object_attrs : PaperTrail.serializer.dump(object_attrs)
    data         = { event: 'publish', object: object_value, whodunnit: whodunnit }
    versions     = resource.send(resource.class.versions_association_name)
    attributes   = resource.send('merge_metadata', data)
    versions.present? && override ? versions.last.update!(attributes) : versions.create!(attributes)
  end
end
