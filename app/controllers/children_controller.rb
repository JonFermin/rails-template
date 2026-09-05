# frozen_string_literal: true

class ChildrenController < ApplicationController
  def index
    @children = policy_scope(Child).includes(:classroom).order(:name)
  end

  def show
    @child = policy_scope(Child).with_recent_reports.find(params[:id])
    authorize @child
    @daily_reports = @child.daily_reports.recent_first
  end
end
