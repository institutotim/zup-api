class MigrateNamespaces
  include Sidekiq::Worker

  def perform(namespace_id)
    namespace = Namespace.find_by(default: true)

    Namespace.transaction do
      [Group, User, Reports::Item, Reports::Perimeter, Inventory::Item,
       Case, ChatRoom].each do |klass|
        klass.where(namespace_id: namespace_id).update_all(namespace_id: namespace.id)
      end

      Inventory::Category.where(namespace_id: namespace_id).update_all(namespace_id: nil)
      Reports::Category.where(namespace_id: namespace_id).update_all(namespace_id: nil)

      [Reports::CategorySetting, Reports::StatusCategory].each do |klass|
        klass.where(namespace_id: namespace_id).delete_all
      end
    end
  end
end
