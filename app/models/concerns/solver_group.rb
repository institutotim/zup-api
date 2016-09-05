module SolverGroup
  extend ActiveSupport::Concern

  included do
    belongs_to :default_solver_group, foreign_key: :default_solver_group_id,
                                      class_name: 'Group'
  end

  def solver_groups=(groups)
    self.solver_groups_ids = groups.map(&:id)
  end

  def solver_groups
    Group.where(id: solver_groups_ids)
  end
end
