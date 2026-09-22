class Reservation < ApplicationRecord
  belongs_to :users
  belongs_to :courts
  belongs_to :payments
  validates :current_date, presence: true
  attribute :current_date, :date, default: -> { Date.current }
  validates :start_time, presence: true, comparison: {less_than: :end_time, greather_than: :current_date}
  validates :end_time, presence: true, comparison: {greather_than: :start_time}

  validates :not_past_dates
  validates :overlapping_reservations
  validates :court_reservations

  private 
  def not_past_dates
    return if current_date.blank?
    errors.add(:current_date, "Date cannot be in the past") if current_date < Date.current
  end

  def overlapping_reservations
    return if court_id.blank? || current_date.blank? || start_time.blank? || end_time.blank?

    overlapping = Reservation.where(court_id: court_id, current_date: current_date)
                              .where.not(id: id)
                              .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "The court is already booked") if overlapping.exists?
  end

  def court_reservations # Validates the court´s schedule
      return if court_id.blank? || current_date.blank? || start_time.blank? || end_time.blank?

      day_key = Schedule.day_weeks.key(current_date.wday) # '.wday' it´s a Ruby´s method that return a num from 0 to 6 representing the day of the week.
      schedule_of_court = Schedule.where(court_id: court_id, day_week: day_key)
                          .where("start_time <= ? AND end_time >= ?", start_time, end_time)
                          .exists?
      unless schedule_of_court
        return errors.add(:base, "The court is not available in that date/time")
      end
    end
  end
