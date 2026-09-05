# frozen_string_literal: true

module Ai
  # The single chokepoint for model calls: enforces the daily budget, asks for a structured response, refuses to act
  # on anything that does not validate against the schema, and logs metadata only (never prompt or response text).
  class Completion
    MAX_TOKENS = 600
    BUDGET_KEY = "ai:completions:daily"

    def initialize(prompt, schema:, client: Ai.client, store: Rails.cache)
      @prompt = prompt
      @schema = schema
      @client = client
      @store = store
    end

    def call
      consume_budget!
      message = request
      log(message)
      raise Refused, "provider declined the request" if message.stop_reason == :refusal

      parse(message)
    end

    private
      attr_reader :prompt, :schema, :client, :store

      # Cost cap: a rolling daily counter in the cache, separate from the per-user request rate limit. Like
      # ActionController's rate_limit, a store that cannot count (the test env's null store) means no cap.
      def consume_budget!
        limit = Rails.configuration.ai[:daily_call_limit]
        count = store.increment(BUDGET_KEY, 1, expires_in: 1.day)
        return if count.nil? || count <= limit

        raise BudgetExhausted, "daily model call limit (#{limit}) reached"
      end

      def request
        client.messages.create(
          model: Rails.configuration.ai[:model],
          max_tokens: MAX_TOKENS,
          system_: prompt.fetch(:system),
          messages: [ { role: :user, content: prompt.fetch(:user) } ],
          output_config: { format: { type: "json_schema", schema: schema } }
        )
      rescue Anthropic::Errors::APIError => e
        raise ProviderError, "#{e.class.name.demodulize}: #{e.message}"
      end

      def log(message)
        Rails.logger.info(
          "ai.completion model=#{message.model} stop_reason=#{message.stop_reason} " \
          "input_tokens=#{message.usage.input_tokens} output_tokens=#{message.usage.output_tokens}"
        )
      end

      def parse(message)
        data = JSON.parse(text_of(message))
        problems = JSONSchemer.schema(schema).validate(data).map { |error| error.values_at("data_pointer", "type") }
        raise InvalidResponse, "response failed schema: #{problems.map { |p| p.join(" ") }.join(", ")}" if problems.any?

        data
      rescue JSON::ParserError => e
        raise InvalidResponse, "response was not JSON: #{e.message}"
      end

      def text_of(message)
        message.content.find { |block| block.type == :text }&.text.to_s
      end
  end
end
