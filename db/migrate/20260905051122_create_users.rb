# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      # Single-table inheritance: Owner and Attendant share authentication but are distinct domain models.
      t.string :type, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
