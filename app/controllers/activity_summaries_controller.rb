# frozen_string_literal: true

class ActivitySummariesController < ApplicationController
  # Model calls cost money: throttled per user, on top of the app-wide daily cap in Ai::Completion.
  rate_limit to: 5, within: 1.hour, by: -> { Current.user.id }, name: "activity_summaries",
             with: -> { redirect_back_or_to children_path, alert: "Too many summaries requested. Try again later." }

  def create
    daily_report = policy_scope(DailyReport).find(params[:daily_report_id])
    authorize daily_report, :summarize?

    ActivitySummaryJob.perform_later(daily_report)
    redirect_to daily_report, notice: "Summary is on its way."
  end
end
