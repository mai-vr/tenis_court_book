class AddFieldsToClubModel < ActiveRecord::Migration[8.1]
  def change
    add_column :clubs, :phone, :string
    add_column :clubs, :email, :string
    add_column :clubs, :description, :string
  end
end
