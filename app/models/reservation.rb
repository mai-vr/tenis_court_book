class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :court
  belongs_to :payment, optional: true
  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending
  validates :current_date, presence: true
  attribute :current_date, :date, default: -> { Date.current }
  validates :start_time, presence: true, comparison: { less_than: :end_time }
  validates :end_time, presence: true, comparison: { greater_than: :start_time }

  validate :not_past_dates
  validate :one_hour_slot
  validate :overlapping_reservations
  validate :club_schedule
  validate :court_must_be_available
  validate :court_must_be_available

  after_create :mark_court_as_booked

  private 

  def mark_court_as_booked
    court.update!(status: :booked)
  end

  def court_must_be_available
    return if court.blank?

    unless court.available?
      errors.add(:court, "is not available for new bookings")
    end
  end

  def court_must_be_available
    return if court.blank?

    if court.booked? || court.maintenance?
      errors.add(:court, "is not available for bookings at this time")
    end
  end

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

  def one_hour_slot
    return if start_time.blank? || end_time.blank?

    errors.add(:base, "A reservation must be exactly one hour") unless end_time - start_time == 1.hour
  end

  def club_schedule
    return if court.blank? || current_date.blank? || start_time.blank? || end_time.blank?

    day_key = Schedule.day_weeks.key(current_date.wday)
    schedule_exists = court.club.schedules
                           .where(day_week: day_key)
                           .where("start_time <= ? AND end_time >= ?", start_time, end_time)
                           .exists?

    errors.add(:base, "The court is not available in that date/time") unless schedule_exists
  end
end