class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :reservations  
  belongs_to :club, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  enum :role, {user:0, superadmin: 1, club_admin: 2}, default: :user
  # validates :club, if: :club_admin?

  def backoffice?
    club_admin? || superadmin?
  end
end
