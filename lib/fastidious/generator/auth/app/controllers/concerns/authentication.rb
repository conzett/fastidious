# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  # NOTE: Current user is provided to ease the Devise transition. Other
  # private methods/helpers are left as close to the Rails defaults as
  # possible given other refactors

  included do
    before_action :require_authentication
    helper_method :authenticated?
    helper_method :current_user
  end

  private

  def authenticated? = current_session.present?

  def current_session
    return unless cookies.signed[:session_id]

    @current_session ||= Session.find_by id: cookies.signed[:session_id]
  end

  def current_user
    return unless cookies.signed[:session_id]

    @current_user ||= current_session&.user
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def require_authentication
    current_session || request_authentication
  end

  # NOTE: TODO: Figure out edge cases for landing on sessions/new
  # and just doing the right thing when it's a JSON request?

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  # NOTE: This skips the optimization of presetting the session ivar
  # but that's a fast query in the context of sign-in and it decouples
  # the session instance from this concern more

  def start_new_session(value)
    cookies.signed.permanent[:session_id] = {
      httponly: true,
      same_site: :lax,
      value:
    }
  end

  def terminate_session
    cookies.delete :session_id
  end
end
