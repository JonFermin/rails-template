# frozen_string_literal: true

module Pets
  class CheckOutsController < ApplicationController
    def create
      pet = policy_scope(Pet).find(params[:pet_id])
      authorize pet, :check_out?

      pet.attendances.open.take!.close
      redirect_to pet, notice: "#{pet.name} is checked out."
    end
  end
end
