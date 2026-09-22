# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.find_or_create_by!(email_address: "admin@tenis.com") do |user|
  user.password = "Pepe123"
  user.password_confirmation = "Pepe123"
  user.role = :admin
end


loc1 = Location.create!(
  street: "Avenida del Libertador",
  number: 14500,
  city: "Buenos Aires"
)

Club.create!(
  name: "Buenos Aires Lawn Tennis Club",
  location: loc1
)

loc2 = Location.create!(
  street: "Avenida Figueroa Alcorta",
  number: 7200,
  city: "Buenos Aires"
)

Club.create!(
  name: "Club Ciudad de Buenos Aires",
  location: loc2
)

loc3 = Location.create!(
  street: "Calle 53",
  number: 480,
  city: "La Plata"
)

Club.create!(
  name: "La Plata Tennis Club",
  location: loc3
)
