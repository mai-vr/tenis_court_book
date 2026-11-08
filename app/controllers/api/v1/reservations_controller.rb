class Api::V1::ReservationsController < Api::V1::BaseController
    before_action :authenticate_request!
    before_action :set_club, except: :my_reservations

    def index
      reservations = @club.reservations.select(
        :id,
        :court_id,
        :current_date,
        :start_time,
        :end_time,
        :status
      )

      render json: reservations
    end
    
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
            begin
              uri = URI.parse("https://api.brevo.com/v3/smtp/email")
              request = Net::HTTP::Post.new(uri)
              request["accept"] = "application/json"
              request["api-key"] = ENV['BREVO_API_KEY']
              request["content-type"] = "application/json"
              request.body = {
                sender: { email: "maitereynosov@gmail.com", name: "Tenis Court Book" },
                to: [{ email: current_user&.email_address || "cliente@example.com" }],
                subject: "¡Reserva confirmada en el club!",
                htmlContent: "<html><body><h1>¡Hola! Tu reserva ha sido exitosa.</h1><p>Cancha: #{@reservation.court_id}</p><p>Fecha: #{@reservation.current_date}</p></body></html>"
              }.to_json

              response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                http.request(request)
              end
            rescue => e
              Rails.logger.error("Error enviando correo con Brevo API: #{e.message}")
            end

            render json: {
              message: "Reserva realizada con éxito.",
              reservation: @reservation.as_json(include: [ :court, :payment ])
            }, status: :created
          else
            raise ActiveRecord::Rollback
          end

          if @reservation && !@reservation.persisted?
            render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
          end
        end  
      end

      def destroy
        reservation = current_user.reservations.find(params[:id]) # Only the user can delete their reservation.

        reservation.destroy!

        render json: {
          message: "Reserva eliminada correctamente."
        }, status: :ok
        rescue ActiveRecord::RecordNotFound
        render json: {
          error: "Reserva no encontrada."
        }, status: :not_found
      end

      def my_reservations
        reservations = current_user.reservations
                                  .includes(court: { club: :location }, payment: nil)
                                  .order(current_date: :desc, start_time: :desc)

        render json: reservations.as_json(
          only: %i[
            id
            current_date
            start_time
            end_time
            status
          ],
          include: {
            court: {
              only: %i[
                id
                description
                material
                indoor
                price_per_hour
                status
              ],
              include: {
                club: {
                  only: %i[
                    id
                    name
                    description
                    phone
                    email
                  ],
                  include: {
                    location: {
                      only: %i[
                        id
                        street
                        number
                        city
                      ]
                    }
                  }
                }
              }
            },
            payment: {
              only: %i[
                id
                payment_method
                total
                already_payed
                status
              ]
            }
          }
        )
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
