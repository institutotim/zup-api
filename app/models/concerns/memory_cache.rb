require 'digest/sha1'

module MemoryCache
  extend ActiveSupport::Concern

  module ClassMethods
    def cached_find(object_ids)
      key = cache_key

      # If everything changed and the cache isn't valid anymore
      # We fetch those objects, store in @memory_cache and return them
      if ENV['DISABLE_MEMORY_CACHE'] == 'true' || @memory_cache.blank? || @memory_cache[key].nil?
        @memory_cache = {
          key => {}
        }

        objects = joins(:permission).find(object_ids)

        objects.each do |obj|
          @memory_cache[key][obj.id] = obj
        end
      else # Else, we try to get some of them from the cache
        objects = []
        missing_object_ids = []

        object_ids.each do |group_id|
          if @memory_cache[key][group_id]
            objects << @memory_cache[key][group_id]
          else
            missing_object_ids << group_id
          end
        end

        unless missing_object_ids.empty?
          joins(:permission).find(missing_object_ids).each do |group|
            @memory_cache[key][group.id] = group
            objects << @memory_cache[key][group.id]
          end
        end
      end

      objects
    end

    def cache_key
      Digest::SHA1.hexdigest(
        Group.count.to_s + \
        Group.unscoped.order(updated_at: :desc).limit(1).pluck(:updated_at).first.to_s + \
        GroupPermission.unscoped.order(updated_at: :desc).limit(1).pluck(:updated_at).first.to_s
      )
    end

    def cache_version
      cache_key
    end
  end
end
