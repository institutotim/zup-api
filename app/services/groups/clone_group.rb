module Groups
  class CloneGroup
    def self.clone!(group_id)
      new(group_id).clone!
    end

    def initialize(group_id)
      @group = Group.find(group_id)
    end

    def clone!
      make_new_group
      build_permissions
      new_group.save!

      new_group
    end

    private

    def make_new_group
      attrs = group.attributes.except('id', 'created_at', 'updated_at')
      self.new_group = Group.new(attrs)
      set_uniq_name
    end

    def set_uniq_name
      i = 1
      i += 1 while Group.exists?(name: "Cópia #{i} de #{new_group.name}")
      new_group.name.prepend("Cópia #{i} de ")
    end

    def build_permissions
      return unless group.permission

      permission_params = group.permission.attributes.except('id', 'group_id')
      new_group.build_permission(permission_params)
    end

    attr_reader :group
    attr_accessor :new_group
  end
end
