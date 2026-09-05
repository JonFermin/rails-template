# frozen_string_literal: true

# The COPPA boundary: a guardian sees only children they are linked to through a Guardianship; an educator sees only
# the children in their classrooms.
class ChildPolicy < ApplicationPolicy
  def index? = true

  def show?
    return record.guardians.include?(user) if user.guardian?

    record.classroom.educator == user
  end

  # Attendance and reports are written by the classroom's educator only.
  def check_in? = user.educator? && show?
  def check_out? = check_in?
  def report? = check_in?

  class Scope < Scope
    def resolve
      return scope.merge(user.children) if user.guardian? || user.educator?

      scope.none
    end
  end
end
