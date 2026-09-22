class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true
      t.date :current_date
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
