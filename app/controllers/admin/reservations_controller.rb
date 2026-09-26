module Admin  
  class ReservationsController < ApplicationController
    before_action :set_club

    def show
      @reservation = @club.reservations.find(params[:id])
      authorize @reservation
    end

    def new
      @reservation = @club.reservations.build(reservation_params)
      
      @available_courts = fetch_available_courts

      authorize @reservation
    end

      def create
          @reservation = @club.reservations.build(formatted_reservation_params)
          
          @reservation.user = current_user
          @reservation.status = :pending
          # @reservation = current_user.reservations.build(reservation_params)
          # @reservation.user = current_user
          authorize @reservation

          if @reservation.save
            redirect_to new_club_reservation_payment_path(@club, @reservation), notice: "Reserva realizada exitosamente."
          else
            @available_courts = fetch_available_courts
            render :new, status: :unprocessable_entity
              puts @reservation.errors.full_messages
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


    def formatted_reservation_params
      p = reservation_params
      return p if p.empty?

      date = p[:current_date].is_a?(String) ? Date.parse(p[:current_date]) : p[:current_date]
      start_t = parse_time(p[:start_time], date)
      end_t = parse_time(p[:end_time], date)

      p.merge(
        current_date: date,
        start_time: start_t,
        end_time: end_t
      )
    rescue ArgumentError
      p
    end

    def parse_time(time_value, date)
      return time_value if time_value.blank? || time_value.is_a?(Time) || time_value.is_a?(ActiveSupport::TimeWithZone)

      Time.zone.parse("#{date} #{time_value}")
    end

    def fetch_available_courts
      return @club.courts.available if @reservation.current_date.blank? || @reservation.start_time.blank? || @reservation.end_time.blank?


        req_start = @reservation.start_time.strftime("%H:%M")
        req_end   = @reservation.end_time.strftime("%H:%M")

        @club.courts.available.reject do |court|
          court.reservations.where(current_date: @reservation.current_date)
                          .where.not(status: :cancelled)
                          .any? do |existing_res|
            
            exist_start = existing_res.start_time.strftime("%H:%M")
            exist_end   = existing_res.end_time.strftime("%H:%M")

            req_start < exist_end && req_end > exist_start
          end
        end
      end
  end
end