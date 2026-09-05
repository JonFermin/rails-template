# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :attendant, null: false, foreign_key: { to_table: :users }
      t.datetime :checked_in_at, null: false
      t.datetime :checked_out_at

      t.timestamps
    end
    # At most one open attendance (no checkout yet) per pet.
    add_index :attendances, :pet_id, unique: true, where: "checked_out_at IS NULL",
              name: "index_attendances_open_per_pet"
  end
end
