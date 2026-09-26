module Admin  
  class PaymentsController < ApplicationController
    before_action :set_club
    before_action :set_reservation

    def new
      @payment = Payment.new(total: @reservation.court.price_per_hour)
    end

    def create
      @payment = Payment.new(payment_params)  
      @payment.total = @reservation.court.price_per_hour
      @payment.already_payed = 0

      if @payment.save
        @reservation.update!(payment: @payment, status: :confirmed)
        redirect_to club_reservation_path(@club, @reservation), notice: "Payment created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private
    
    def set_club
      @club = Club.find(params[:club_id])
    end

    def set_reservation
      @reservation = @club.reservations.find(params[:reservation_id])
    end

    def payment_params
      params.require(:payment).permit(:payment_method)
    end
  end
end