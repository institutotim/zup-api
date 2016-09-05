module Permissions
  class API < Base::API
    helpers do
      def load_resource
        if params[:resource_type] == 'groups'
          Group.find(params[:resource_id])
        else
          User.service.find(params[:resource_id])
        end
      end
    end

    namespace '/permissions/:resource_type/:resource_id/' do
      desc 'Return all permissions, by type and object'
      get do
        authenticate!

        resource = load_resource

        if resource.is_a? User
          validate_permission!(:manage_services, User)
        else
          validate_permission!(:view, resource)
        end

        permissions = Groups::PermissionManager.new(resource)
        permissions.fetch
      end

      desc 'Add permissions to a resource'
      params do
        optional :objects_ids, type: Array,
                desc: 'Array of ids of the object type'
        requires :permissions, type: Array,
                desc: 'Array of permission names'
      end
      post ':permissions_type' do
        authenticate!

        resource = load_resource

        if resource.is_a? User
          validate_permission!(:manage_services, User)
        else
          validate_permission!(:edit, resource)
        end

        permissions = Groups::PermissionManager.new(resource)

        permissions_type = params[:permissions_type].to_sym

        params[:permissions].each do |permission_name|
          permission_class = GroupPermission::TYPES[permissions_type][permission_name]
          next unless permission_class

          if permission_class.is_a? Array
            objects_ids = params[:objects_ids].map(&:to_i)
            permissions.add_with_objects(permission_name, objects_ids)
          elsif permission_class == GroupPermission::Boolean
            permissions.add(permission_name)
          end
        end

        {
          message: 'Permissões atualizadas com sucesso.'
        }
      end

      desc 'Remove permissions from a resource'
      params do
        requires :permission, type: String,
                 desc: 'Permission name'
        optional :object_id, type: Integer,
                 desc: 'The object id to remove from'
      end
      delete ':permissions_type' do
        authenticate!

        resource = load_resource

        if resource.is_a? User
          validate_permission!(:manage_services, User)
        else
          validate_permission!(:edit, resource)
        end

        permissions = Groups::PermissionManager.new(resource)

        permissions_type = params[:permissions_type].to_sym
        permission_name = params[:permission]
        permission_class = GroupPermission::TYPES[permissions_type][permission_name]

        if permission_class.is_a? Array
          object_id = params[:object_id].to_i
          permissions.remove_with_objects(permission_name, [object_id])
        elsif permission_class == GroupPermission::Boolean
          permissions.remove(permission_name)
        end

        {
          message: 'Permissão removida com sucesso.'
        }
      end
    end
  end
end
