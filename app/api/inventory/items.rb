module Inventory::Items
  class API < Base::API
    helpers do
      def load_category(inventory_category_id = nil)
        Inventory::Category.find(inventory_category_id || safe_params[:category_id])
      end
    end

    # Lists/searches for inventory items
    # /inventory/items
    resources :items do
      desc 'List all items'
      paginate per_page: 25
      params do
        optional :position, type: Hash,
          desc: 'Hash of position data'
        optional :inventory_category_id,
          desc: 'ID (or array of ids of the desired inventory category'
        optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
        optional :sort, type: String,
                 desc: 'The field to sort the items. Either created_at, updated_at or id'
        optional :order, type: String,
                 desc: 'Either ASC or DESC.'
        optional :display_type, type: String,
                 desc: 'Can be \'full\' or \'basic\''
      end
      get do
        search_params = {
          filters: safe_params[:filters],
          position: safe_params[:position],
          limit: safe_params[:limit],
          sort: safe_params[:sort],
          order: safe_params[:order]
        }

        unless safe_params[:inventory_category_id].blank?
          if safe_params[:inventory_category_id].is_a?(Array)
            search_params[:categories] = safe_params[:inventory_category_id].map do |cid|
              Inventory::Category.find(cid)
            end
          else
            search_params[:categories] = [Inventory::Category.find(safe_params[:inventory_category_id])]
          end
        end

        items = Inventory::SearchItems.new(current_user, search_params).search
        if safe_params[:position].nil?
          items = paginate(items)
        end

        garner.bind(Inventory::ItemCacheControl.new(items)).options(expires_in: 15.minutes) do
          { items: Inventory::Item::Entity.represent(items, display_type: safe_params[:display_type], user: current_user, serializable: true, only: return_fields) }
        end
      end

      desc 'Get an individual item'
      get ':id' do
        item = Inventory::Item.find(safe_params[:id])

        { item: Inventory::Item::Entity.represent(item, user: current_user, only: return_fields) }
      end
    end

    # /inventory/categories/:category_id/items
    resources :categories do
      route_param :category_id do
        resources :items do
          desc 'Create an item'
          params do
            optional :title, type: String
            optional :inventory_status_id, type: Integer
            requires :data
          end
          post do
            authenticate!
            validate_permission!(:create, Inventory::Item)

            category = load_category

            if safe_params[:inventory_status_id]
              status = category.statuses.find(safe_params[:inventory_status_id])
            end

            creator = Inventory::CreateItemFromCategoryForm.new(
              category: category,
              user: current_user,
              data: safe_params['data'],
              status: status,
              namespace_id: app_namespace_id
            )
            item = creator.create!
            item.reload

            {
              message: 'Item created successfully',
              item: Inventory::Item::Entity.represent(item, user: current_user)
            }
          end

          desc "Shows item's info"
          get ':id' do
            category = load_category
            item = category.items.includes(:user, :category, :status, :locker, data: [:field, :images, :attachments]).find(safe_params[:id])

            { item: Inventory::Item::Entity.represent(item, user: current_user, only: return_fields) }
          end

          desc 'Destroy item'
          delete ':id' do
            authenticate!
            category = load_category

            item = category.items.find(safe_params[:id])
            validate_permission!(:delete, item)
            item.destroy!

            { message: 'Inventory item successfully destroyed!' }
          end

          desc "Update item's info"
          params do
            optional :data, type: Hash, desc: 'The item data where each element is a content for a category field'
            optional :inventory_status_id, type: Integer,
                     desc: 'The inventory status you want'
          end
          put ':id' do
            authenticate!

            category = load_category
            item = category.items.find(safe_params[:id])

            validate_permission!(:edit, item)

            if !item.locked? || (item.locked? && item.locker == current_user)
              check_formulas = true

              if safe_params[:inventory_status_id]
                status = category.statuses.find(safe_params[:inventory_status_id])

                if item.status != status
                  item.reload.update!(status: status)
                  check_formulas = false

                  Inventory::CreateHistoryEntry.new(item, current_user)
                                              .create('status',
                                                      'Alterou o status do inventário.',
                                                      status)
                end
              end

              if safe_params[:data]
                updater = Inventory::UpdateItemData.new(item, safe_params[:data], current_user, check_formulas)
                item = updater.update!
              end

              {
                message: 'Inventory item updated successfully!',
                item: Inventory::Item::Entity.represent(item, user: current_user, only: return_fields)
              }
            else
              {
                message: 'Form locked',
                locker: User::Entity.represent(item.locker),
                locked_at: item.locked_at
              }
            end
          end

          desc 'Update the access to the inventory item, locking it'
          patch ':id/update_access' do
            authenticate!

            item = Inventory::Item.find(safe_params[:id])
            validate_permission!(:edit, item)

            Inventory::ItemLocking.new(item, current_user).lock!
          end
        end
      end
    end
  end
end
