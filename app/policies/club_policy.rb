class ClubPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    superadmin? || (club_admin? && user.club.nil?)
  end

  alias new? create?

  def update?
    superadmin? || owner?
  end

  alias edit? update?

  def destroy?
    superadmin? || owner?
  end

  class Scope < Scope # Dependiendo del rol, los accesos que tendrá el usuario.
    def resolve
      if user&.superadmin?
        scope.all
      elsif user&.club_admin?
        scope.where(id: user.club_id) # El slub_admin solo ve su propio club.
      else
        scope.none
      end
    end
  end

  private

  def superadmin?
    user.present? && user.superadmin?
  end

  def club_admin?
    user.present? && user.club_admin?
  end

  def owner?
    club_admin? && user.club_id == record.id
  end
end
