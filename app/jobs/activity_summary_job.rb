# frozen_string_literal: true

# Thin: decides whether to run and hands off. Runs on its own queue so the worker pool for model calls can be sized
# or paused independently of everything else.
class ActivitySummaryJob < ApplicationJob
  queue_as :ai

  discard_on Ai::BudgetExhausted, Ai::Refused
  retry_on Ai::InvalidResponse, attempts: 2
  retry_on Ai::ProviderError, wait: :polynomially_longer, attempts: 3

  def perform(daily_report)
    return if daily_report.summarized?

    Ai::DailySummaryGenerator.new(daily_report).call
  end
end
