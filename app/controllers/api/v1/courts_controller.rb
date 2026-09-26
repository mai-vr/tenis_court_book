class Api::V1::CourtsController < Api::V1::BaseController
      before_action :set_club

      # GET /api/v1/clubs/:club_id/courts
      def index
        render json: @club.courts, status: :ok
      end

      # GET /api/v1/clubs/:club_id/courts/:id
      def show
        @court = @club.courts.find(params[:id])
        render json: @court, status: :ok
      end

      private

      def set_club
        @club = Club.find(params[:club_id])
      end
end
