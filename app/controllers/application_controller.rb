# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Forgetting a policy is the failure mode; make it loud (docs/security-checklist.md → Pundit consistently).
  # Predicates rather than `only:/except:` because Rails raises for callbacks that name actions a controller lacks.
  after_action :verify_authorized, unless: :listing?
  after_action :verify_policy_scoped, if: :listing?

  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  private
    # Rails 8's generated authentication exposes the user through Current, not a `current_user` helper.
    def pundit_user
      Current.user
    end

    def listing?
      action_name == "index"
    end

    def deny_access
      redirect_back_or_to pets_path, alert: "You aren't allowed to do that.", status: :see_other
    end
end
