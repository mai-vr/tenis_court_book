require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  def setup
    @club = clubs(:two)

    @schedule = Schedule.new(
      day_week: :monday,
      start_time: Time.zone.parse("08:00"),
      end_time: Time.zone.parse("20:00"),
      club: @club
    )
  end

  test "es válido cuando la hora de cierre es posterior a la de apertura" do
    assert @schedule.valid?
  end

  test "no es válido si la hora de fin es igual o anterior a la hora de inicio" do
    @schedule.end_time = Time.zone.parse("08:00")
    refute @schedule.valid?
  end
end