# frozen_string_literal: true

# The owner-consent boundary: an owner sees only pets they are linked to through an Ownership; an attendant sees only
# the pets in their locations.
class PetPolicy < ApplicationPolicy
  def index? = true

  def show?
    return record.owners.include?(user) if user.owner?

    record.location.attendant == user
  end

  # Attendance and reports are written by the location's attendant only.
  def check_in? = user.attendant? && show?
  def check_out? = check_in?
  def report? = check_in?

  class Scope < Scope
    def resolve
      return scope.merge(user.pets) if user.owner? || user.attendant?

      scope.none
    end
  end
end
