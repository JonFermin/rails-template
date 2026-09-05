# frozen_string_literal: true

module Children
  class CheckOutsController < ApplicationController
    def create
      child = policy_scope(Child).find(params[:child_id])
      authorize child, :check_out?

      child.attendances.open.take!.close
      redirect_to child, notice: "#{child.name} is checked out."
    end
  end
end
