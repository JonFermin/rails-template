# frozen_string_literal: true

class CreateGuardianships < ActiveRecord::Migration[8.1]
  def change
    create_table :guardianships do |t|
      t.references :child, null: false, foreign_key: true
      t.references :guardian, null: false, foreign_key: { to_table: :users }
      t.string :relationship, null: false

      t.timestamps
    end
    add_index :guardianships, %i[ child_id guardian_id ], unique: true
  end
end
