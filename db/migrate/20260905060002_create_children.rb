# frozen_string_literal: true

class CreateChildren < ActiveRecord::Migration[8.1]
  def change
    create_table :children do |t|
      t.string :name, null: false
      t.date :birthdate, null: false
      t.references :classroom, null: false, foreign_key: true

      t.timestamps
    end
  end
end
