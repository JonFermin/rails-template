# frozen_string_literal: true

# A minimal, idempotent slice for poking at the app locally: one location, its attendant, one pet and one
# owner. Sign in as either user with the password below. Development data only — nothing here is a fixture.
password = "password"

attendant = Attendant.find_or_create_by!(email_address: "attendant@example.com") do |user|
  user.name = "Sam Attendant"
  user.password = password
end

owner = Owner.find_or_create_by!(email_address: "owner@example.com") do |user|
  user.name = "Riley Owner"
  user.password = password
end

location = Location.find_or_create_by!(name: "Sunflower Room", attendant: attendant)
pet = Pet.find_or_create_by!(name: "Ada", location: location) { |p| p.birthdate = 3.years.ago.to_date }
Ownership.find_or_create_by!(pet: pet, owner: owner) { |o| o.relationship = "primary" }
