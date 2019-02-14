class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :location
      t.datetime :date
      t.boolean :private_event
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
