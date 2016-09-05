require 'digest/sha1'

class CustomCacheControl
  attr_reader :klass, :params, :user, :namespace_id

  def initialize(klass, user, namespace_id, params = {})
    @klass = klass
    @user = user
    @namespace_id = namespace_id
    @params = params
  end

  def garner_cache_key
    params.delete(:token)
    return SecureRandom.hex if params[:without_cache]

    if last_updated_at
      unique_string = "#{last_updated_at}/user/#{user.try(:id) || 0}/namespace/#{namespace_id.to_i}/#{group_permission_last_updated_at}/#{params}/#{klass.count}"
      "#{klass.name.titleize.downcase}/#{Digest::SHA1.hexdigest(unique_string)}"
    end
  end

  private

  def last_updated_at
    @last_updated_at ||= klass.unscoped.order(updated_at: :desc).try(:first).try(:updated_at)
  end

  def group_permission_last_updated_at
    @group_permission_last_updated_at ||= user.groups_permissions.maximum(:updated_at)
  rescue
    '0'
  end
end
