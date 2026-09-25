class ReservationPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def new?
    create?
  end

  alias new? create?
end