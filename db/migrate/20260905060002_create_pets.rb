# frozen_string_literal: true

class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.string :name, null: false
      t.date :birthdate, null: false
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
