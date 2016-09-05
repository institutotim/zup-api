module Reports::Stats
  class API < Base::API
    desc 'Return stats for desired category'
    params do
      optional :category_id,
               desc: 'The reports category, you can pass an array of ids or a single id'
      optional :begin_date, type: Date,
               desc: 'The minimum date to filter'
      optional :end_date, type: Date,
               desc: 'The maximum date to filter'
    end
    get 'stats' do
      if safe_params[:category_id].present?
        category_ids = safe_params[:category_id]
      else
        category_ids = Reports::Category.all.pluck(:id)
      end

      stats = Reports::GetStats.new(
        category_ids,
        app_namespace_id,
        begin_date: safe_params[:begin_date],
        end_date:   safe_params[:end_date]
      ).fetch

      {
        stats: stats
      }
    end
  end
end
