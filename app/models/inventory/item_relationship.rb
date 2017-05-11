class Inventory::ItemRelationship < Inventory::Base
  self.table_name = 'inventory_items_relationships'

  belongs_to :inventory,
    class_name: 'Inventory::Item',
    foreign_key: :relationship_id

  belongs_to :father,
    class_name: 'Inventory::Item',
    foreign_key: :inventory_item_id

  validates :inventory_item_id, uniqueness: { scope: :relationship_id }
  validates :relationship_id,   uniqueness: { scope: :inventory_item_id }

  after_create :create_relation
  after_destroy :destroy_relation

  private

  def create_relation
    Inventory::ItemRelationship.find_or_create_by(
      relationship_id: inventory_item_id,
      inventory_item_id: relationship_id
    )
  end

  def destroy_relation
    Inventory::ItemRelationship.where(
      relationship_id: inventory_item_id,
      inventory_item_id: relationship_id
    ).delete_all
  end
end
