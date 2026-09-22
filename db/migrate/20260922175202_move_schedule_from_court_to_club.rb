class MoveScheduleFromCourtToClub < ActiveRecord::Migration[8.1]
  def change
    remove_reference :schedules, :court, foreign_key: true
    add_reference :schedules, :club, foreign_key: true, null: false
  end
end
