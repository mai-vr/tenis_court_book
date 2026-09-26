class Api::V1::ReservationsController < Api::V1::BaseController
    before_action :set_club
    before_action :authenticate_request!
      def create
        @court = @club.courts.find_by(id: reservation_params[:court_id])

        unless @court
          return render json: { error: "Cancha no encontrada en este club." }, status: :not_found
        end

        ActiveRecord::Base.transaction do
          @payment = Payment.create!(
            payment_method: params[:payment_method] || "cash",
            total: @court.price_per_hour,
            already_payed: @court.price_per_hour,
            status: :in_process
          )

          @reservation = @club.reservations.build(formatted_reservation_params)
          @reservation.court = @court
          @reservation.user_id = params[:user_id] || current_user&.id
          @reservation.payment = @payment
          @reservation.status = :pending

          if @reservation.save
            render json: {
              message: "Reserva realizada con éxito.",
              reservation: @reservation.as_json(include: [:court, :payment])
            }, status: :created
          else
            raise ActiveRecord::Rollback
          end
        end

        if @reservation && !@reservation.persisted?
          render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_club
        @club = Club.find(params[:club_id])
      end

      def reservation_params
        params.require(:reservation).permit(:current_date, :start_time, :end_time, :court_id)
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
    end

