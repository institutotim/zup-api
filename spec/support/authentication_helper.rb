class Hash
  def auth(user)
    self[:token] = user.last_access_key
    self
  end
end

module AuthenticationHelper
  def auth(user, namespace_id = nil)
    headers = {}

    if user
      namespace_id ||= user.namespace_id
      headers['X-App-Token'] = user.last_access_key
    end

    if namespace_id
      headers['X-App-Namespace'] = namespace_id
    end

    headers
  end
end
