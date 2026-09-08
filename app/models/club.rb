class Club < ApplicationRecord
  belongs_to :locations
  has_many :courts
  validates :name, presence: true, uniqueness: true, length: {in: 2..25}
end
