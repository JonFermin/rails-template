# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  # Nothing to authorize: the session itself is the resource.
  skip_after_action :verify_authorized
  # Login is an auth endpoint: throttled per IP (docs/security-checklist.md → Rack::Attack or equivalent).
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
