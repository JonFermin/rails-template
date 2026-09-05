# frozen_string_literal: true

# A minimal, idempotent slice for poking at the app locally: one classroom, its educator, one child and one
# guardian. Sign in as either user with the password below. Development data only — nothing here is a fixture.
password = "password"

educator = Educator.find_or_create_by!(email_address: "educator@example.com") do |user|
  user.name = "Sam Educator"
  user.password = password
end

guardian = Guardian.find_or_create_by!(email_address: "guardian@example.com") do |user|
  user.name = "Riley Guardian"
  user.password = password
end

classroom = Classroom.find_or_create_by!(name: "Sunflower Room", educator: educator)
child = Child.find_or_create_by!(name: "Ada", classroom: classroom) { |c| c.birthdate = 3.years.ago.to_date }
Guardianship.find_or_create_by!(child: child, guardian: guardian) { |g| g.relationship = "parent" }
