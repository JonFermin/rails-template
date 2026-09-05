# frozen_string_literal: true

# The person responsible for a pet. The Pundit boundary: an owner only ever sees their own pets.
class Owner < User
  has_many :ownerships, dependent: :destroy
  has_many :pets, through: :ownerships
end
