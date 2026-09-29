class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :reservations
  belongs_to :club, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  enum :role, { user: 0, superadmin: 1, club_admin: 2 }, default: :user

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { in: 2..50 }
  validates :last_name, presence: true, length: { in: 2..50 }
  validates :password, length: { minimum: 4 }
  validates :role, presence: true, inclusion: { in: roles.keys }

  validates :club, presence: { message: "es obligatorio para administradores de club" }, if: :club_admin?
  validate :no_club_regular_user, if: :user?

  def backoffice?
    club_admin? || superadmin?
  end

  private
  def no_club_regular_user
    if club_id.present?
      errors.add(:club, "A client user cant have a club asociated")
    end
  end
end
