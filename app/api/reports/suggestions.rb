module Reports::Suggestions
  class API < Base::API
    helpers do
      def load_suggestion
        Reports::Suggestion.find(params[:id])
      end
    end

    namespace :suggestions do
      desc 'Return all suggestion that current user can see'
      paginate per_page: 5
      get do
        authenticate!

        validate_permission!(:group, Reports::Item)

        suggestions = Reports::Suggestion.active.includes(:category)

        if user_permissions.cannot?(:manage, Reports::Item)
          category_ids = user_permissions.reports_categories_visible

          if category_ids.empty?
            suggestions = Reports::Suggestion.none
          else
            suggestions = suggestions.by_categories(category_ids)
          end
        end

        {
          suggestions: Reports::Suggestion::Entity.represent(
            paginate(suggestions),
            only: return_fields
          )
        }
      end

      desc 'Ignore the suggestion'
      put '/:id/ignore' do
        authenticate!

        validate_permission!(:group, Reports::Item)

        suggestion = load_suggestion
        suggestion.status = 'ignored'
        suggestion.save!

        {
          suggestion: suggestion.entity
        }
      end

      desc 'Group the suggestion'
      put '/:id/group' do
        authenticate!

        validate_permission!(:group, Reports::Item)

        suggestion = load_suggestion

        reports = Reports::Item.find(suggestion.reports_items_ids)

        Reports::GroupItems.new(current_user, reports).group!

        suggestion.status = 'grouped'
        suggestion.save!

        {
          suggestion: suggestion.entity
        }
      end
    end
  end
end
