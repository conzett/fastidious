# frozen_string_literal: true

class PasswordResetEmailsController < ApplicationController
  skip_before_action :require_authentication

  # NOTE: No way for this to "fail" so no if/else needed
  # NOTE: Result of `mail` is a wrapper around mail message
  # NOTE: Consider adding rate limiting

  # "Password reset instructions sent
  # (if user with that email address exists)."

  def new; end

  def create
    @password_reset_email = PasswordsMailer.reset_email password_reset_email_params
    @password_reset_email.deliver_later

    head :no_content, location: new_user_session_path
  end

  private

  def password_reset_email_params
    params.expect password_reset_email: %i[email_address]
  end
end
