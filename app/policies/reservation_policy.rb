class ReservationPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def new?
    create?
  end

  def show?
    true
  end

  alias new? create?
end