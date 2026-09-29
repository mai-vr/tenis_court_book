class ReservationMailer < ApplicationMailer
    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.reservation_mailer.confirmation_email.subject
    #

    default from: "tenic-court@books.com"

    def confirmation_email(reservation)
      @reservation = reservation
      @user = reservation.user
      @court = reservation.court
      @club = @court.club

      mail(
        to: @user.email_address,
        subject: "Confirmacion de la reserva - {@club.name}"
      )
    end
end
