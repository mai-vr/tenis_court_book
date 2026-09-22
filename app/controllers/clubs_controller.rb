class ClubsController < ApplicationController
  before_action :set_club, only: %i[show edit update destroy]

  def index
    @clubs = Club.includes(:location, :schedules).order(:name)
  end

  def show
    @schedules = @club.schedules.order(:day_week, :start_time)
  end

  def new
    @club = Club.new
    @location = Location.new
    authorize @club
  end

  def create
    @club = Club.new(club_params)
    @location = Location.new(location_params)
    authorize @club

    Club.transaction do
      @location.save!
      @club.location = @location
      @club.save!
    end

    redirect_to @club, notice: "Club created successfully."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def edit
    @location = @club.location
    authorize @club
  end

  def update
    authorize @club
    if @club.update(club_params) && @club.location.update(location_params)
      redirect_to @club, notice: "Club updated successfully."
    else
      @location = @club.location
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @club
    @club.destroy
    redirect_to clubs_path, notice: "Club deleted successfully."
  end

  private

  def set_club
    @club = Club.find(params[:id])
  end

  def club_params
    params.expect(club: %i[name phone email description])
  end

  def location_params
    params.expect(location: %i[street number city])
  end
end