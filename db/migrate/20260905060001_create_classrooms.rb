# frozen_string_literal: true

class CreateClassrooms < ActiveRecord::Migration[8.1]
  def change
    create_table :classrooms do |t|
      t.string :name, null: false
      t.references :educator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
