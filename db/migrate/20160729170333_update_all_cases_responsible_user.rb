class UpdateAllCasesResponsibleUser < ActiveRecord::Migration
  def up
    Case.where(responsible_user: nil).find_in_batches do |kases|
      kases.each do |kase|
        kase.valid? && kase.update(responsible_user: kase.case_steps.last.try(:responsible_user_id))
      end
    end
  end

  def down
    Case.where.not(responsible_user: nil).update_all(responsible_user: nil)
  end
end
