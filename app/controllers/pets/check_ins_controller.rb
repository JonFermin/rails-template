# frozen_string_literal: true

module Pets
  class CheckInsController < ApplicationController
    def create
      pet = policy_scope(Pet).find(params[:pet_id])
      authorize pet, :check_in?

      pet.attendances.create!(attendant: Current.user, checked_in_at: Time.current)
      redirect_to pet, notice: "#{pet.name} is checked in."
    end
  end
end
