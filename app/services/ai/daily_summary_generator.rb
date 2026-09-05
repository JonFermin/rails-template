# frozen_string_literal: true

module Ai
  # Turns a DailyReport into an ActivitySummary for the child's guardians.
  #
  # Data about a minor leaves the application here, so the prompt is built from an explicit allowlist and nothing
  # else: no name, no ids, no photos, and not the educator's free-text notes. Add a field to PROMPT_FIELDS only with
  # a second reviewer (docs/security-checklist.md → AI-specific rules, COPPA).
  class DailySummaryGenerator
    PROMPT_FIELDS = %i[ mood nap_minutes meals ].freeze

    SYSTEM_PROMPT = <<~TEXT
      You write a short, warm end-of-day recap for a child's guardians from structured notes an educator recorded.
      The child is a minor. Do not invent details, do not guess a name or age, and do not give medical advice.
      Respond with a summary of at most three sentences and up to three short highlights.
    TEXT

    SCHEMA = {
      "type" => "object",
      "properties" => {
        "summary" => { "type" => "string", "description" => "At most three sentences, under 400 characters." },
        "highlights" => { "type" => "array", "items" => { "type" => "string" }, "description" => "Up to three." }
      },
      "required" => %w[ summary highlights ],
      "additionalProperties" => false
    }.freeze

    def initialize(daily_report, client: Ai.client)
      @daily_report = daily_report
      @client = client
    end

    def call
      audit
      response = Completion.new(prompt, schema: SCHEMA, client: client).call
      daily_report.create_activity_summary!(body: response.fetch("summary"), highlights: response.fetch("highlights"))
    rescue ActiveRecord::RecordInvalid => e
      raise InvalidResponse, "summary did not meet our limits: #{e.record.errors.full_messages.join(", ")}"
    end

    # Public so tests can assert exactly which fields are sent (docs/testing-philosophy.md → prompt structure).
    def prompt_payload
      PROMPT_FIELDS.index_with { |field| daily_report.public_send(field) }
    end

    private
      attr_reader :daily_report, :client

      def prompt
        { system: SYSTEM_PROMPT, user: "Write the recap for this report:\n#{prompt_payload.to_json}" }
      end

      # Field names only, so the audit trail shows what kind of data was sent without duplicating the values.
      def audit
        Rails.logger.info("ai.daily_summary_generator report=#{daily_report.id} fields=#{PROMPT_FIELDS.join(",")}")
      end
  end
end
