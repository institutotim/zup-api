module Flows::Steps::Triggers::TriggerConditions
  class API < Base::API
    resources ':trigger_id/trigger_conditions' do
      desc 'Delete a Trigger Condition'
      delete ':id' do
        authenticate!
        # permission by Trigger because it is you dependent
        validate_permission!(:delete, Trigger)

        condition = Trigger.find(safe_params[:trigger_id]).trigger_conditions.find(safe_params[:id])
        condition.user = current_user
        condition.inactive!
        { message: I18n.t(:trigger_condition_deleted) }
      end
    end
  end
end
