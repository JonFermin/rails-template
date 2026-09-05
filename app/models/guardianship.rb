# frozen_string_literal: true

# Named for the relationship, not the tables it joins (docs/naming-conventions.md).
class Guardianship < ApplicationRecord
  RELATIONSHIPS = %w[ parent grandparent foster_parent legal_guardian ].freeze

  belongs_to :child
  belongs_to :guardian

  validates :relationship, inclusion: { in: RELATIONSHIPS }
  validates :guardian_id, uniqueness: { scope: :child_id }
end
