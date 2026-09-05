# frozen_string_literal: true

class CreateActivitySummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_summaries do |t|
      t.references :daily_report, null: false, foreign_key: true, index: { unique: true }
      t.text :body, null: false
      t.string :highlights, array: true, null: false, default: []

      t.timestamps
    end
  end
end
