# frozen_string_literal: true

class CreateDailyReports < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_reports do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :attendant, null: false, foreign_key: { to_table: :users }
      t.date :reported_on, null: false
      t.string :mood, null: false
      t.integer :nap_minutes, null: false, default: 0
      t.text :meals
      t.text :notes

      t.timestamps
    end
    add_index :daily_reports, %i[ pet_id reported_on ], unique: true
  end
end
