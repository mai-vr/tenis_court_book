class Club < ApplicationRecord
  belongs_to :location
  has_many :courts, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :reservations, through: :courts
  has_many :users, dependent: :nullify 

  has_one_attached :logo # Active storage.

  validates :name, presence: true, uniqueness: {case_sensitive: false}, length: {in: 2..25}
  validates :phone, presence: true, uniqueness: true, length: {in: 10..15}, format: { with: /\A\+?[0-9]+\z/, message: "Letters are invalid as a phone number"}
  validates :description, presence: true, length: {maximum: 150}
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP, message: "It must be a valid email address"}, allow_blank: true
  # 'URI::MailTo::EMAIL_REGEXP' - expresión regular nativa de Ruby para validar correos.
  validates :location, presence: true

  validate :valid_logo

  private
  def valid_logo
    return unless logo.attached?

    if logo.blob.byte_size > 5.megabytes
      errors.add(:logo, "Logo is too big (max. 5 MB)")
    end

    types_allowed = ["image/jpeg", "image/jpg", "image/png", "image/webp"]
    unless types_allowed.include?(logo.blob.content_type)
      errors.add(:logo, "The image must be '.jpg', '.png', '.jpeg', or '.webp'")
    end
  end
end
