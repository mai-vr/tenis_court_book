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

club1 = Club.find_or_create_by!(name: "BA Lawn Tennis") do |club|
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

club2 = Club.find_or_create_by!(name: "Club Ciudad BA") do |club|
  club.location = loc2
  club.phone = "+541147005678"
  club.description = "Complejo deportivo con canchas de cemento y polvo de ladrillo."
  club.email = "deportes@clubciudadba.com"
end

loc3 = Location.find_or_create_by!(
  street: "Calle 53",
  number: 480,
  city: "La Plata"
)

club3 = Club.find_or_create_by!(name: "La Plata Tennis") do |club|
  club.location = loc3
  club.phone = "+542214229900"
  club.description = "Club histórico en el centro de La Plata."
  club.email = "info@laplatatennis.com"
end

Court.find_or_create_by!(club: club1, description: "Meryl") do |court|
  court.material = "Polvo de ladrillo"
  court.indoor = false
  court.price_per_hour = 15000.0
  court.status = 0 
end

Court.find_or_create_by!(club: club1, description: "Emma") do |court|
  court.material = "Polvo de ladrillo"
  court.indoor = false
  court.price_per_hour = 18000.0
  court.status = 0
end

Court.find_or_create_by!(club: club1, description: "Cate") do |court|
  court.material = "Cemento"
  court.indoor = true
  court.price_per_hour = 20000.0
  court.status = 0
end

Court.find_or_create_by!(club: club2, description: "Natalie") do |court|
  court.material = "Cemento"
  court.indoor = true
  court.price_per_hour = 14000.0
  court.status = 0
end

Court.find_or_create_by!(club: club2, description: "Julia") do |court|
  court.material = "Cemento"
  court.indoor = true
  court.price_per_hour = 17000.0
  court.status = 0
end

Court.find_or_create_by!(club: club2, description: "Nicole") do |court|
  court.material = "Polvo de ladrillo"
  court.indoor = false
  court.price_per_hour = 19000.0
  court.status = 0
end

Court.find_or_create_by!(club: club3, description: "Audrey") do |court|
  court.material = "Polvo de ladrillo"
  court.indoor = false
  court.price_per_hour = 13000.0
  court.status = 0
end

Court.find_or_create_by!(club: club3, description: "Jodie") do |court|
  court.material = "Polvo de ladrillo"
  court.indoor = false
  court.price_per_hour = 16000.0
  court.status = 0
end

Court.find_or_create_by!(club: club3, description: "Sandra") do |court|
  court.material = "Polvo de ladrillo"
  court.indoor = false
  court.price_per_hour = 14500.0
  court.status = 0
end

[club1, club2, club3].each do |club|
  (1..3).each do |day|
    Schedule.find_or_create_by!(club: club, day_week: day) do |schedule|
      schedule.start_time = "08:00:00"
      schedule.end_time = "22:00:00"
    end
  end
end