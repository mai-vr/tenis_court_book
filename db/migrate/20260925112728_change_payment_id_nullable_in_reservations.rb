class ChangePaymentIdNullableInReservations < ActiveRecord::Migration[8.1]
  def change
    change_column_null :reservations, :payment_id, true
  end
end
