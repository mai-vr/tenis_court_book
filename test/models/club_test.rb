require "test_helper"

class ClubTest < ActiveSupport::TestCase
  def setup
    @location = locations(:one)
    @club = Club.new(
      name: "Tenis Central",
      phone: "2214567890",
      description: "Club de tenis con canchas de polvo de ladrillo",
      location: @location
    )
  end

  test "es válido con todos los atributos requeridos" do
    assert @club.valid?
  end

  test "requiere un nombre único y de longitud válida" do
    @club.name = "A" # Demasiado corto
    refute @club.valid?
    assert_includes @club.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "teléfono solo debe contener dígitos numéricos" do
    @club.phone = "221-AAABB"
    refute @club.valid?
    assert_includes @club.errors[:phone], "solo debe contener números (opcionalmente con prefijo +)"
  end

  test "no es válido sin una ubicación asociada" do
    @club.location = nil
    refute @club.valid?
    assert_includes @club.errors[:location], "can't be blank"
  end
end
