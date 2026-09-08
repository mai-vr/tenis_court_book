class CourtsController < ApplicationController
    before_action :find_court, only: %i[show edit update destroy]

    def index
        @courts = Court.includes(:club).all
    end

    def show
    end

    def new
        @court = Court.new
        authorize @court
        @clubs = Club.all
    end

    def create
        @court = Court.new(court_params)
        authorize @court

        if @court.save 
            redirect_to @court
        else
            @clubs = Club.all
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @clubs = Club.all
        authorize @court
    end

    def update
        authorize @court
        if @court.update(court_params)
            redirect_to @court
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @court
        @court.destroy
        redirect_to courts_path
    end

    private

    def find_court
        @court = Court.find(params[:id])
    end

    def court_params
        params.expect(court: [:club_id, :material, :status, :indoor, :description, :price_per_hour])
    end
end
