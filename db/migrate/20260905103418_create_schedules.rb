class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.date :day_week
      t.time :start_time
      t.time :end_time
      t.references :court, null: false, foreign_key: true

      t.timestamps
    end
  end
end
