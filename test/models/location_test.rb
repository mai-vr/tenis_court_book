require "test_helper"

class LocationTest < ActiveSupport::TestCase
  def setup
    @location = Location.new(
      street: "Calle 35",
      number: 1129,
      city: "La Plata"
    )
  end

    test "es válida con todos los atributos presentes" do
      location = Location.new(street: "Calle Nueva", number: 999, city: "Rosario")
      assert location.valid?
    end

    test "no permite duplicar exactamente la misma dirección (calle, número y ciudad)" do
      existing = locations(:one)
      duplicate = Location.new(street: existing.street, number: existing.number, city: existing.city)

      refute duplicate.valid?
      assert_includes duplicate.errors[:street], "ya existe con ese número y ciudad"
    end

  test "número de calle debe ser un entero mayor a cero" do
    @location.number = -10
    refute @location.valid?
    assert_includes @location.errors[:number], "must be greater than 0"
  end
end
