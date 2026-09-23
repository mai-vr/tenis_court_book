class ReservationPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  alias new? create?
end