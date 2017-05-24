module EventLogs
  class API < Base::API
    resources :event_logs do
      desc 'Return events logs paginated'
      get do
        authenticate!

        validate_permission!(:view, EventLog)

        logs = EventLog.includes(:user)
        logs = paginate(logs)

        {
          event_logs: EventLog::Entity.represent(logs, only: return_fields)
        }
      end
    end
  end
end
