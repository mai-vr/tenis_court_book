class Api::V1::ClubsController < Api::V1::BaseController
    def index
        @clubs = Club.includes(:location).all
        render json: @clubs, include: :location, status: :ok
      end

      def show
        @club = Club.includes(:location, :schedules).find(params[:id])
        render json: @club, include: %i[location schedules], status: :ok
      end
end
