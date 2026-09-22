class Club < ApplicationRecord
  belongs_to :location
  has_many :courts, dependent: :destroy
  has_many :schedules, dependent: :destroy
  validates :name, presence: true, uniqueness: true, length: {in: 2..25}
  validates :phone, presence: true, uniqueness: true, length: {in: 10..15}, format: { without: /\A[a-zA-Z]+\z/, message: "Letters are invalid as a phone number"}
  validates :description, length: {maximum: 150}
end
