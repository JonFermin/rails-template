# frozen_string_literal: true

class PetsController < ApplicationController
  def index
    @pets = policy_scope(Pet).includes(:location).order(:name)
  end

  def show
    @pet = policy_scope(Pet).with_recent_reports.find(params[:id])
    authorize @pet
    @daily_reports = @pet.daily_reports.recent_first
  end
end
