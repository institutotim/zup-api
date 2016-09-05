class BuildPermissions
  attr_reader :user, :struct

  def initialize(user)
    @user = user
    @struct = OpenStruct.new
  end

  def permissions
    if user.service?
      permissions_for_service
    else
      permissions_for_user
    end

    struct
  end

  private

  def group_ids
    user.groups.pluck(:id)
  end

  def permissions_for_user
    Group.cached_find(group_ids).each do |group|
      build_permissions(group.permission)
    end
  end

  def permissions_for_service
    build_permissions(user.permission)
  end

  def build_permissions(permission)
    GroupPermission.permissions_columns.each do |column|
      value = permission.public_send(column)

      if value.is_a?(Array)
        @struct[column] ||= []
        @struct[column] += value
        @struct[column].uniq!
      elsif value.nil?
        # Check if value needed to be array
        # This is needed because sometimes the cached_find
        # is returning incorrect and old data form columns,
        # before we defined in database that every array-typed column
        # returns an empty array if no content is stored.
        # FIXME: This needs to be fixed clearing triggers and functions
        # from production databases.

        # Get permission
        perm_type = nil
        GroupPermission::TYPES.each do |_mod, perms|
          perm = perms[column]

          if perm && perm.is_a?(Array)
            perm_type = perm[1]
          elsif perm
            perm_type = perm
          end

          break if perm_type
        end

        if perm_type && perm_type == Array
          @struct[column] = []
        end
      else
        @struct[column] = value unless struct[column] === true
      end
    end
  end
end
