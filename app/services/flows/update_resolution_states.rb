module Flows
  class UpdateResolutionStates
    attr_reader :flow, :current_user

    def initialize(flow, current_user)
      @flow = flow
      @current_user = current_user
    end

    def update!(params)
      current_rs_ids = flow.resolution_states.pluck(:id) # ids of the existing resolution states for this flow

      ActiveRecord::Base.transaction do
        # If creating or updating the default state, change the old one to false
        new_default_rs = params.select { |rs| rs['default'] }
        fail(ActiveRecord::RecordInvalid.new(flow)) if new_default_rs.count > 1

        if new_default_rs.any?
          new_default_rs = new_default_rs.first
          current_default = flow.resolution_states.where(default: true).first
          current_default.update_attribute(:default, false) if current_default && current_default.id != new_default_rs['id']
        end

        # Add new resolution states
        params.select { |rs| !rs['id'] }
            .each { |rs| flow.resolution_states.create!(rs.merge!(flow_id: flow.id, user: current_user)) }

        # Update existing resolution states
        params.select { |rs| rs['id'] } # items with an id field are meant to be updated
            .select { |rs| current_rs_ids.include?(rs['id'].to_i) } # so they must exist in the current_rs_ids
            .each { |rs| flow.resolution_states.find(rs['id']).update!(rs.merge!(user: current_user)) }

        # Prune old resolution states
        new_rs_ids = params.map { |rs| rs['id'] } # ids of the new resolution state set
        rs_ids_to_remove = current_rs_ids.select { |rs_id| !new_rs_ids.include?(rs_id) } # if not present they must be removed
        flow.resolution_states.where(id: rs_ids_to_remove).update_all(active: false)
      end

      flow
    end
  end
end
