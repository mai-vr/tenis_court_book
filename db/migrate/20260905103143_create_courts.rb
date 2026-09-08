class CreateCourts < ActiveRecord::Migration[8.1]
  def change
    create_table :courts do |t|
      t.string :material
      t.integer :status
      t.boolean :indoor
      t.text :description
      t.decimal :price_per_hour
      t.references :club, null: false, foreign_key: true

      t.timestamps
    end
  end
end
