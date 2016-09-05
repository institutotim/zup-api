module Groups
  class PermissionManager
    attr_reader :group, :permissions,
                :permissions_data

    def initialize(group)
      @group = group
      @permissions = group.permission.reload
      @permissions_data = {}.with_indifferent_access
    end

    def fetch
      compile_permissions_data!

      data = []

      objects_permissions = {}
      permissions_data.each do |name, permission_data|
        permission_klass = permission_data[:permission_klass]
        object_klass = permission_data[:object_klass]
        permission_type = permission_data[:permission_type]

        if permission_klass == Array
          (permissions.send(name) || []).each do |object_id|
            objects_permissions[permission_type] ||= {}
            objects_permissions[permission_type][object_klass] ||= {}
            objects_permissions[permission_type][object_klass][object_id] ||= []
            objects_permissions[permission_type][object_klass][object_id] << name
          end
        elsif permissions.send(name)
          data << {
            permission_type: permission_type,
            permission_names: name
          }
        end
      end

      objects_permissions.each do |permission_type, klasses|
        klasses.each do |klass, objects|
          objects.each do |object_id, names|
            if klass
              object = klass.unscoped.find_by(id: object_id)

              if object
                data << {
                  permission_type: permission_type,
                  object_class: klass.name,
                  object: klass::Entity.represent(object),
                  permission_names: names.uniq
                }
              end
            end
          end
        end
      end

      data
    end

    def add_with_objects(permission_name, objects_ids)
      validate_permission_name(permission_name)
      validate_objects_existence(permission_name, objects_ids)

      permissions.atomic_cat(permission_name, objects_ids)
      permissions.touch
    end

    def remove_with_objects(permission_name, objects_ids)
      validate_permission_name(permission_name)

      objects_ids.each do |id|
        permissions.atomic_remove(permission_name, id)
      end

      permissions.touch
    end

    def add(permission_name)
      validate_permission_name(permission_name)

      permissions.update(permission_name => true)
    end

    def remove(permission_name)
      validate_permission_name(permission_name)

      permissions.update(permission_name => false)
    end

    def compile_permissions_data!
      return unless @permissions_data.empty?

      GroupPermission::TYPES.each do |name, permissions|
        permissions.each do |permission_name, klasses|
          if klasses.is_a?(Array)
            object_klass, permission_klass = klasses[0], klasses[1]
          else
            permission_klass = klasses
          end

          @permissions_data[permission_name] = {
            object_klass: object_klass,
            permission_klass: permission_klass,
            permission_type: name
          }
        end
      end
    end

    private

    def validate_permission_name(permission_name)
      unless permissions.respond_to?(permission_name)
        fail "Permission doesn't exists: #{permission_name}"
      end
    end

    def validate_objects_existence(permission_name, objects_ids)
      compile_permissions_data!

      permission_data = permissions_data[permission_name]
      klass = permission_data[:object_klass]

      fail "Permission #{permission_name} is non-existent" unless permission_data && klass

      objects_ids.each do |id|
        klass.unscoped.find_by!(id: id)
      end
    end
  end
end
