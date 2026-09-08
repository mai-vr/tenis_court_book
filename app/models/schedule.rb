class Schedule < ApplicationRecord
  belongs_to :courts
  enum :day_week, {
    sunday: 0, monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6
  }
  validates :day_week, presence: true
  validates :start_time, comparison: {greather_than: Date.current, less_than: :end_time}
  validates :end_time, comparison: {greather_than: :start_time}

  validate :overlapping_schedules

  private
  def overlapping_schedules
    return if court_id.blank? || day_week.blank? || start_time.blank? || end_time.blank?

    overlapping = Schedule.where(court_id: court_id, day_week: day_week)
                           .where.not(id: id)
                           .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "There is already an shedule to that court that day") if overlapping.exists?
  end
end
