class AddClubToUser < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :club, foreign_key: true, null: true
  end
end
