# frozen_string_literal: true

class DailyReportPolicy < ApplicationPolicy
  def show? = child_policy.show?
  def create? = child_policy.report?
  def summarize? = show?

  class Scope < Scope
    def resolve
      scope.where(child: ChildPolicy::Scope.new(user, Child).resolve)
    end
  end

  private
    def child_policy
      ChildPolicy.new(user, record.child)
    end
end
