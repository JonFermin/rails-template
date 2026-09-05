# frozen_string_literal: true

class DailyReportsController < ApplicationController
  before_action :set_pet, only: %i[ new create ]

  def show
    @daily_report = policy_scope(DailyReport).includes(:activity_summary, :pet).find(params[:id])
    authorize @daily_report
  end

  def new
    @daily_report = @pet.daily_reports.build(reported_on: Date.current)
    authorize @daily_report
  end

  def create
    @daily_report = @pet.daily_reports.build(daily_report_params.merge(attendant: Current.user))
    authorize @daily_report

    if @daily_report.save
      redirect_to @daily_report, notice: "Report saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_pet
      @pet = policy_scope(Pet).find(params[:pet_id])
    end

    def daily_report_params
      params.expect(daily_report: [ :reported_on, :mood, :nap_minutes, :meals, :notes, photos: [] ])
    end
end
