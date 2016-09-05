class Inventory::ItemHistory < Inventory::Base
  include ArrayRelate

  belongs_to :item, class_name: 'Inventory::Item', foreign_key: 'inventory_item_id'
  belongs_to :user
  has_many :item_data_histories, class_name: 'Inventory::ItemDataHistory',
                                 foreign_key: 'inventory_item_history_id',
                                 inverse_of: :item_history,
                                 autosave: true

  validates :kind, presence: true
  validates :action, presence: true
  validates :user, presence: true
  validates :item, presence: true

  array_belongs_to :objects, polymorphic: 'object_type'

  # Override from ArrayRelate
  # TODO: Hmm, this doesn't seems right
  def objects=(objects)
    return [] if objects.blank?

    if kind == 'fields' && objects.is_a?(Hash)
      # If these are item data, we need to
      # generate a history for them aswell
      build_item_data_history(objects)
      objects = objects.keys.map(&:field)
    end

    objects = [objects] unless objects.is_a?(Array)

    self.objects_ids = objects.map(&:id)
    self.object_type = objects.first.class.name
  end

  class Entity < Grape::Entity
    expose :id
    expose :inventory_item_id
    expose :user, using: User::Entity
    expose :kind
    expose :action
    expose :item_data_histories, as: :fields_changes,
                                 using: Inventory::ItemDataHistory::Entity,
                                 if: -> (object, _) { object.kind == 'fields' }
    expose :objects
    expose :created_at

    def objects
      if object.objects.any?
        if options[:only]
          options[:only] = options[:only].select do |i|
            i.is_a?(Hash) && i.keys.include?(:objects)
          end

          options[:only] = options[:only].first[:objects] if options[:only].any?
        end

        object.object_entity_class.represent(object.objects, options)
      else
        []
      end
    end
  end

  private

  def build_item_data_history(objects)
    objects.each do |item_data, changes|
      item_data_histories.build(
        item_data: item_data,
        previous_content: changes[:old],
        new_content: changes[:new]
      )
    end
  end
end
