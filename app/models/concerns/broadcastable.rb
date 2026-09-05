# frozen_string_literal: true

# Pushes a Turbo page refresh to everyone watching the child's page whenever the record changes.
#
# A refresh carries no data: subscribers re-request the page through the authorized controller, so nothing about a
# minor is written to the cable. Only pages that already passed Pundit render the signed stream name.
#
# Turbo debounces the refreshes and sends them through a job, so a report and its summary landing together cost
# one refresh, not two.
module Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes_to :child
  end
end
