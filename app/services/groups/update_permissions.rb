module Groups
  class UpdatePermissions
    def self.update(groups_ids, object, permission_name)
      if groups_ids && groups_ids.any?
        # Remove permission of groups_ids
        Group.that_includes_permission(permission_name, object.id).each do |group|
          next if groups_ids.include?(group.id)
          group.permission.atomic_remove(permission_name, object.id)
        end

        groups_ids.each do |group_id|
          group = Group.find(group_id)

          unless group.permission.send(permission_name).include?(object.id)
            group.permission.atomic_append(permission_name, object.id)
          end
        end
      end
    end
  end
end
