require "test_helper"

class CourtTest < ActiveSupport::TestCase
  def setup
    @club = clubs(:one)
    @court = Court.new(
      description: "Cancha N1",
      price_per_hour: 2500,
      material: "Polvo de ladrillo",
      indoor: false,
      status: :available,
      club: @club
    )
  end

  test "es válida con atributos requeridos" do
    assert @court.valid?
  end

  test "precio por hora debe ser un número mayor a cero" do
    @court.price_per_hour = 0
    refute @court.valid?
    assert_includes @court.errors[:price_per_hour], "must be greater than 0"
  end

  test "no permite nombres de cancha duplicados dentro del mismo club" do
    @court.save!
    cancha_duplicada = Court.new(
      description: "Cancha N1",
      price_per_hour: 3000,
      material: "Cemento",
      indoor: true,
      club: @club
    )
    refute cancha_duplicada.valid?
    assert_includes cancha_duplicada.errors[:description], "ya existe en este club"
  end
end