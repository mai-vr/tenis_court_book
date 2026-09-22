class SchedulePolicy < ApplicationPolicy
  def create?
    admin?
  end

  alias new? create?

  private

  def admin?
    user.present? && user.admin?
  end
end