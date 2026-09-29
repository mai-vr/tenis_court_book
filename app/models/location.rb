class Location < ApplicationRecord
    has_many :clubs
    validates :city, presence: true, length: {in: 2..25}, format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑ\s.-]+\z/, message: "Only words are allow"}
    validates :number, presence: true, numericality: {only_integer: true, greater_than: 0}
    validates :street, presence: true, length: {in: 2..25}, uniqueness: {scope: [:number, :city], case_sensitive: false, message: "ya existe con ese número y ciudad"}
end
