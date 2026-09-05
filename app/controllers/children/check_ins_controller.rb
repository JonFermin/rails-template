# frozen_string_literal: true

module Children
  class CheckInsController < ApplicationController
    def create
      child = policy_scope(Child).find(params[:child_id])
      authorize child, :check_in?

      child.attendances.create!(educator: Current.user, checked_in_at: Time.current)
      redirect_to child, notice: "#{child.name} is checked in."
    end
  end
end
