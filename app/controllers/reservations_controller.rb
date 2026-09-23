class ReservationsController < ApplicationController
  before_action :set_club

  def new
    @reservation = @club.reservations.build(reservation_params)
    
    @available_courts = @club.courts.available.reject do |court|
      Reservation.exists?(
        court: court,
        current_date: @reservation.current_date,
        start_time: @reservation.start_time,
        end_time: @reservation.end_time
      )
    end

    authorize @reservation
  end

    def create
        @reservation = current_user.reservations.build(reservation_params)
        authorize @reservation

        if @reservation.save
        redirect_to club_path(@club), notice: "Reserva realizada exitosamente."
        else
        @available_courts = @club.courts.available.reject do |court|
            Reservation.exists?(
            court: court,
            current_date: @reservation.current_date,
            start_time: @reservation.start_time,
            end_time: @reservation.end_time
            )
        end
        render :new, status: :unprocessable_entity
        end
    end

  private

    def set_club
        @club = Club.find(params[:club_id])
    end

  def reservation_params
    params.fetch(:reservation, {}).permit(:current_date, :start_time, :end_time, :court_id)
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
