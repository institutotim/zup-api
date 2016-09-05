class Inventory::Section < Inventory::Base
  belongs_to :category, class_name: 'Inventory::Category',
                        foreign_key: 'inventory_category_id',
                        touch: true

  has_many :fields, class_name: 'Inventory::Field',
                    foreign_key: 'inventory_section_id',
                    autosave: true,
                    dependent: :destroy

  validates :title, presence: true
  validates :required, inclusion: { in: [true, false] }

  before_validation :set_default_attributes

  def disable!
    update!(disabled: true)

    # Disable all children fields
    fields.each do |field|
      field.disable! unless field.disabled?
    end
  end

  # Group permissions
  def permissions
    {
      groups_can_view: groups_can_view,
      groups_can_edit: groups_can_edit
    }
  end

  def groups_can_view
    Group.that_includes_permission(:inventory_sections_can_view, id).map(&:id)
  end

  def groups_can_edit
    Group.that_includes_permission(:inventory_sections_can_edit, id).map(&:id)
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :disabled
    expose :required
    expose :location
    expose :inventory_category_id
    expose :position
    expose :fields
    expose :permissions

    def fields
      if options[:user]
        user_permissions = UserAbility.for_user(options[:user])

        if user_permissions.can?(:manage, Inventory::Item) || user_permissions.can?(:edit, object.category) || user_permissions.can?(:create, object.category)
          fields = object.fields
        else
          fields = object.fields.enabled.where(id: user_permissions.inventory_fields_visible)
        end

        if options[:only]
          options[:only] = options[:only].select do |i|
            i.is_a?(Hash) && i.keys.include?(:fields)
          end

          options[:only] = options[:only].first[:fields] if options[:only].any?
        end

        Inventory::Field::Entity.represent(fields, options)
      end
    end
  end

  private

  def set_default_attributes
    self.required = false if required.nil?
    true
  end
end
