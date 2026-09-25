class AddStatusToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :status, :integer
  end
end
