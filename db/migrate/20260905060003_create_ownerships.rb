# frozen_string_literal: true

class CreateOwnerships < ActiveRecord::Migration[8.1]
  def change
    create_table :ownerships do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :relationship, null: false

      t.timestamps
    end
    add_index :ownerships, %i[ pet_id owner_id ], unique: true
  end
end
