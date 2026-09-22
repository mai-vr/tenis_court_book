class Schedule < ApplicationRecord
  belongs_to :club
  enum :day_week, {
    sunday: 0, monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6
  }
  validates :day_week, :start_time, :end_time, presence: true
  validates :start_time, comparison: { less_than: :end_time }, if: -> { start_time.present? && end_time.present? }
  validates :end_time, comparison: { greater_than: :start_time }, if: -> { start_time.present? && end_time.present? }

  validate :overlapping_schedules

  private
  def overlapping_schedules
    return if club_id.blank? || day_week.blank? || start_time.blank? || end_time.blank?

    overlapping = Schedule.where(club_id: club_id, day_week: day_week)
                           .where.not(id: id)
                           .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "There is already an shedule to that court that day") if overlapping.exists?
  end
end
