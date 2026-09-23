class ReservationsController < ApplicationController
  before_action :set_club
  before_action :set_court

  def new
    @reservation = @court.reservations.new(reservation_params)
    @reservation.user = current_user
    authorize @reservation

    unless bookable_slot?
      return redirect_to @club, alert: "That booking slot is not available."
    end
  end

  def create
    @reservation = @court.reservations.new(reservation_params)
    @reservation.user = current_user
    authorize @reservation

    Payment.transaction do
      payment = Payment.create!(
        total: @court.price_per_hour,
        already_payed: 0,
        payment_method: "pending",
        status: :not_paid
      )
      @reservation.payment = payment
      @reservation.save!
    end

    redirect_to @club, notice: "Reservation created successfully."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def set_club
    @club = Club.find(params[:club_id])
  end

  def set_court
    @court = @club.courts.find(params[:court_id])
  end

  def reservation_params
    return {} unless params[:reservation]

    params.require(:reservation).permit(:current_date, :start_time, :end_time)
  end

  def bookable_slot?
    return false unless @reservation.current_date.present? && @reservation.start_time.present? && @reservation.end_time.present?
    return false unless @reservation.end_time - @reservation.start_time == 1.hour
    return false if @reservation.current_date < Date.current

    day_key = Schedule.day_weeks.key(@reservation.current_date.wday)
    schedule_exists = @club.schedules
                         .where(day_week: day_key)
                         .where("start_time <= ? AND end_time >= ?", @reservation.start_time, @reservation.end_time)
                         .exists?
    return false unless schedule_exists

    !Reservation.where(court: @court, current_date: @reservation.current_date)
                .where("start_time < ? AND end_time > ?", @reservation.end_time, @reservation.start_time)
                .exists?
  end
end
