class ChangeDayWeekScheduleToInt < ActiveRecord::Migration[8.1]
  def up
    change_column :schedules, :day_week, :integer
    change_column_null :schedules, :day_week, false
  end

  def down
    change_column_null :schedules, :day_week, true
    change_column :schedules, :day_week, :date
  end
end
