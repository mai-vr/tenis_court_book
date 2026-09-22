class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.decimal :total
      t.decimal :already_payed
      t.string :payment_method
      t.integer :status

      t.timestamps
    end
  end
end
