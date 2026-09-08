class Location < ApplicationRecord
    has_many :clubs
    validates :city, presence: true, length: {in: 2..25}
    validates :number, presence: true, numericality: {greater_than: 0}
    validates :street, presence: true, length: {in: 2..25}
end
