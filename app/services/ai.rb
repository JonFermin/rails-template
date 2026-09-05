# frozen_string_literal: true

# Everything that talks to a language model lives under this namespace. The provider is configured in one place
# (`Ai.client`) and injected everywhere else, so swapping vendors touches this file and Ai::Completion only.
module Ai
  class Error < StandardError; end
  class BudgetExhausted < Error; end
  class ProviderError < Error; end
  class Refused < Error; end
  class InvalidResponse < Error; end

  class << self
    attr_writer :client

    def client
      @client ||= Anthropic::Client.new(api_key: api_key)
    end

    private
      # Credentials first, environment second — never a literal (docs/security-checklist.md).
      def api_key
        Rails.application.credentials.dig(:anthropic, :api_key) || ENV.fetch("ANTHROPIC_API_KEY")
      end
  end
end
