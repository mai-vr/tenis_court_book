class ClubPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  alias new? create?

  def update?
    admin?
  end

  alias edit? update?

  def destroy?
    admin?
  end

  private

  def admin?
    user.present? && user.admin?
  end
end