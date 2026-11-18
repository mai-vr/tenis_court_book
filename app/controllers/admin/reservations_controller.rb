module Admin
  class ReservationsController < ApplicationController
    before_action :set_club

    def index
      load_reservations
    end

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
            redirect_to new_admin_club_reservation_payment_path(@club, @reservation), notice: "Reserva realizada exitosamente."
          else
            @available_courts = fetch_available_courts
            render :new, status: :unprocessable_entity
              puts @reservation.errors.full_messages
          end
      end

      def confirm
        @reservation = @club.reservations.find(params[:id])
        @update = false

        if @reservation.pending? && @reservation.current_date >= Date.current
          if @reservation.update(status: :confirmed)
            @message = "La reserva fue confirmada correctamente."
            @message_type = "success"
          else
            @message = "No se pudo confirmar la reserva."
            @message_type = "error"
          end
        else
          @message = "No se puede confirmar esta reserva."
          @message_type = "error"
        end

        respond_to do |format|
          format.html do
            load_reservations
            render :index
          end

          format.turbo_stream do
            if @reservation.confirmed?
              load_reservations
              render :confirm
            else
              load_reservations
              render :index, formats: [:html]
            end
          end
        end
      end

      def cancel
        @reservation = @club.reservations.find(params[:id])
        @updated = false

        if @reservation.pending? && @reservation.current_date >= Date.current
          if @reservation.update(status: :cancelled)
            @message = "La reserva fue cancelada correctamente."
            @message_type = "success"
            @updated = true
          else
            @message = "No se pudo cancelar la reserva."
            @message_type = "error"
          end
        else
          @message = "No se puede cancelar esta reserva."
          @message_type = "error"
        end

        respond_to do |format|
          format.html do
            load_reservations
            render :index
          end

          format.turbo_stream do
            if @updated
              load_reservations
              render :cancel
            else
              load_reservations
              render :index, formats: [:html]
            end
          end
        end
      end

      def destroy
        @reservation = @club.reservations.find(params[:id])

        if @reservation.pending? && @reservation.current_date < Date.current
          if @reservation.destroy
            @message = "La reserva fue eliminada correctamente."
            @message_type = "success"
          else
            @message = "No se pudo eliminar la reserva."
            @message_type = "error"
          end
        else
          @message = "Solo se pueden eliminar reservas pendientes con fecha pasada."
          @message_type = "error"
        end

        load_reservations
        render :index
      end

    private

    def load_reservations
      reservations = @club.reservations.includes(:user, :court, :payment)

      pending = reservations.where(status: :pending)
                       .order(
                         Arel.sql("CASE WHEN current_date >= CURRENT_DATE THEN 0 ELSE 1 END"),
                         current_date: :asc,
                         start_time: :asc
                       )

      @pending_reservations = pending

      @confirmed_reservations = reservations.where(status: :confirmed)
                                            .order(current_date: :desc, start_time: :asc)

      @cancelled_reservations = reservations.where(status: :cancelled)
                                            .order(current_date: :desc, start_time: :asc)
    end

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
                          .where(status: [:pending, :confirmed])
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
                          .where("current_date >= ?", Date.current)
                          .any? do |existing_res|
            exist_start = existing_res.start_time.strftime("%H:%M")
            exist_end   = existing_res.end_time.strftime("%H:%M")

            req_start < exist_end && req_end > exist_start
          end
        end
      end
  end
end
