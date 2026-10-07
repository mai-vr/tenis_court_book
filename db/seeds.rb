# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).


User.find_or_create_by!(email_address: "admin@tenis.com") do |user|
  user.first_name = "Admin"
  user.last_name = "General"
  user.password = "Pepe123"
  user.password_confirmation = "Pepe123"
  user.role = :superadmin
end

loc1 = Location.find_or_create_by!(
  street: "Avenida del Libertador",
  number: 14500,
  city: "Buenos Aires"
)

Club.find_or_create_by!(name: "BA Lawn Tennis") do |club|
  club.location = loc1
  club.phone = "+541147771234"
  club.description = "Sede tradicional de tenis con canchas de polvo de ladrillo."
  club.email = "contacto@balawntennis.com"
end

loc2 = Location.find_or_create_by!(
  street: "Avenida Figueroa Alcorta",
  number: 7200,
  city: "Buenos Aires"
)

Club.find_or_create_by!(name: "Club Ciudad BA") do |club|
  club.location = loc2
  club.phone = "+541147005678"
  club.description = "Complejo deportivo con canchas rápidas y de césped."
  club.email = "deportes@clubciudadba.com"
end

loc3 = Location.find_or_create_by!(
  street: "Calle 53",
  number: 480,
  city: "La Plata"
)

Club.find_or_create_by!(name: "La Plata Tennis") do |club|
  club.location = loc3
  club.phone = "+542214229900"
  club.description = "Club histórico en el centro de La Plata."
  club.email = "info@laplatatennis.com"
end