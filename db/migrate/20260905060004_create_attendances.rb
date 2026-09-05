# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :child, null: false, foreign_key: true
      t.references :educator, null: false, foreign_key: { to_table: :users }
      t.datetime :checked_in_at, null: false
      t.datetime :checked_out_at

      t.timestamps
    end
    # At most one open attendance (no checkout yet) per child.
    add_index :attendances, :child_id, unique: true, where: "checked_out_at IS NULL",
              name: "index_attendances_open_per_child"
  end
end
