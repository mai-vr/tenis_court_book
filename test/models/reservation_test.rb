require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @court = courts(:one)
    @payment = payments(:one)

    @reservation = Reservation.new(
      user: @user,
      court: @court,
      payment: @payment,
      current_date: Date.tomorrow,
      start_time: Time.zone.parse("#{Date.tomorrow} 10:00"),
      end_time: Time.zone.parse("#{Date.tomorrow} 11:00"),
      status: :pending
    )
  end

  test "no es válida sin fecha, hora de inicio o cancha" do
    reservation = Reservation.new
    refute reservation.valid?
    assert reservation.errors[:court].present? || reservation.errors[:court_id].present?
  end
end
