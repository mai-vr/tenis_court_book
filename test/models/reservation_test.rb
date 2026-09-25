require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  setup do
    @reservation = Reservation.new(
      user: users(:one),
      court: courts(:one),
      payment: payments(:one),
      current_date: Date.new(2026, 9, 26),
      start_time: "10:00",
      end_time: "11:00"
    )
  end

  test "accepts a one-hour reservation during the club schedule" do
    assert @reservation.valid?
  end

  test "keeps the court available after creating a reservation" do
    assert @reservation.save

    assert @reservation.court.available?
  end

  test "allows another reservation on the same court in a different slot" do
    assert @reservation.save

    later_reservation = Reservation.new(
      user: users(:two),
      court: @reservation.court,
      current_date: @reservation.current_date,
      start_time: "11:00",
      end_time: "12:00"
    )

    assert later_reservation.valid?, later_reservation.errors.full_messages.to_sentence
  end

  test "rejects overlapping reservations on the same court" do
    assert @reservation.save

    overlapping_reservation = Reservation.new(
      user: users(:two),
      court: @reservation.court,
      current_date: @reservation.current_date,
      start_time: "10:30",
      end_time: "11:30"
    )

    assert_not overlapping_reservation.valid?
    assert_includes overlapping_reservation.errors[:base], "The court is already booked"
  end

  test "rejects reservations longer than one hour" do
    @reservation.end_time = "11:30"

    assert_not @reservation.valid?
    assert_includes @reservation.errors[:base], "A reservation must be exactly one hour"
  end

  test "rejects reservations outside the club schedule" do
    @reservation.start_time = "18:00"
    @reservation.end_time = "19:00"

    assert_not @reservation.valid?
    assert_includes @reservation.errors[:base], "The court is not available in that date/time"
  end
end
