class Court < ApplicationRecord
  belongs_to :club
  has_many :reservations
  validates :club, presence: true
  validates :price_per_hour, numericality: {greater_than: 0}, presence: true
  validates :material, format: {with: /\A[a-zA-Z]+\z/, message: "only allows letters"}, length: {in: 3..20}, presence: true
  validates :description, length: {in: 3..250, too_long: "%{count} characters is the maximum allowed"}, presence: true
  validates :indoor, inclusion: [true, false]
  enum :status, {booked: 0, available: 1, maintenance: 2}
end
