class Api::V1::ClubsController < Api::V1::BaseController
    def index
        @clubs = Club.includes(:location).with_attached_logo.all

        clubs_json = @clubs.map do |club|
          club.as_json(include: :location).merge(logo_url: club_logo_url(club))
        end

        render json: clubs_json, include: :location, status: :ok
      end

      def show
        @club = Club.includes(:location, :schedules).find(params[:id])

        club_json = @club.as_json(include: %i[location schedules]).merge(logo_url: club_logo_url(@club))

        render json: clubs_json, include: %i[location schedules], status: :ok
      end

      def club_logo_url(club) # Devolver la URL del logo adjunto o la imágen por defecto.
        if club.logo.attached?
          rails_blob_url(club.logo)
        else
          ActionController::Base.helpers.asset_url("default_logo.jpg")
        end
      end
end
