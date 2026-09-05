# frozen_string_literal: true

# Named for the relationship, not the tables it joins (docs/naming-conventions.md).
class Ownership < ApplicationRecord
  RELATIONSHIPS = %w[ primary co_owner foster legal_owner ].freeze

  belongs_to :pet
  belongs_to :owner

  validates :relationship, inclusion: { in: RELATIONSHIPS }
  validates :owner_id, uniqueness: { scope: :pet_id }
end
