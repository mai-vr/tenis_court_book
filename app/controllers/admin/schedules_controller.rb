module Admin  
  class SchedulesController < ApplicationController
    before_action :set_club

    def new
      @schedule = @club.schedules.new
      authorize @schedule
    end

    def create
      @schedule = @club.schedules.new(schedule_params)
      authorize @schedule

      if @schedule.save
        redirect_to @club, notice: "Schedule added successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_club
      @club = Club.find(params[:club_id])
    end

    def schedule_params
      params.expect(schedule: %i[day_week start_time end_time])
    end
  end
end