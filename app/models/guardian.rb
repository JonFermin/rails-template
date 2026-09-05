# frozen_string_literal: true

# A parent or other adult responsible for a child. The Pundit boundary: a guardian only ever sees their own children.
class Guardian < User
  has_many :guardianships, dependent: :destroy
  has_many :children, through: :guardianships
end
