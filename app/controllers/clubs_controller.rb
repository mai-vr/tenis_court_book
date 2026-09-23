class ClubsController < ApplicationController
  before_action :set_club, only: %i[show edit update destroy]

  def index
    @clubs = Club.includes(:location, :schedules).order(:name)
  end

  def show
    @schedules = @club.schedules.order(:day_week, :start_time)
    @booking_slots = build_booking_slots
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

  def build_booking_slots
  @schedules.flat_map do |schedule|
    date = next_occurrence(schedule.day_week_before_type_cast, schedule.end_time)
    current_time = schedule.start_time
    slots = []

    while current_time < schedule.end_time
      end_time = current_time + 1.hour
      break if end_time > schedule.end_time

      if date == Date.current && end_time.seconds_since_midnight <= Time.current.seconds_since_midnight
        current_time = end_time
        next
      end

      # Buscamos qué canchas están libres en este bloque específico
      available_courts = @club.courts.available.reject do |court|
        Reservation.exists?(
          court: court,
          current_date: date,
          start_time: current_time,
          end_time: end_time
        )
      end

      slots << {
        date: date,
        start_time: current_time,
        end_time: end_time,
        available_courts: available_courts, # Lista de canchas libres
        available: available_courts.any?    # Disponible si hay al menos una cancha libre
      }

      current_time = end_time
    end

    slots
  end
end

  def next_occurrence(day_of_week, closing_time)
    date = Date.current + ((day_of_week.to_i - Date.current.wday) % 7)
    date += 7 if date == Date.current && closing_time.seconds_since_midnight <= Time.current.seconds_since_midnight
    date
  end
end