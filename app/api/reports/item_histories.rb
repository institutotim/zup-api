module Reports::ItemHistories
  class API < Base::API
    helpers do
      def load_item
        Reports::Item.find(params[:item_id])
      end
    end

    namespace :items do
      route_param :item_id do
        desc 'Search history entries for a report item'
        params do
          optional :kind, type: String, desc: 'O tipo do histórico'
          optional :created_at, type: Hash,
               desc: 'Limit the period of creation, accepts `begin` and `end`'
          optional :user_id, type: Integer, desc: 'ID do usuário'
          optional :object_id, type: Integer, desc: 'Object id related'
        end
        paginate per_page: 25
        get :history do
          authenticate!
          item = load_item

          validate_permission!(:view, item)

          search_params = params.merge(
            item_id: item.id,
            paginator: method(:paginate)
          )

          results = Reports::SearchHistoryEntries.new(search_params).search

          {
            histories: Reports::ItemHistory::Entity.represent(results, only: return_fields)
          }
        end
      end
    end
  end
end
