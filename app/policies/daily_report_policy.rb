# frozen_string_literal: true

class DailyReportPolicy < ApplicationPolicy
  def show? = pet_policy.show?
  def create? = pet_policy.report?
  def summarize? = show?

  class Scope < Scope
    def resolve
      scope.where(pet: PetPolicy::Scope.new(user, Pet).resolve)
    end
  end

  private
    def pet_policy
      PetPolicy.new(user, record.pet)
    end
end
