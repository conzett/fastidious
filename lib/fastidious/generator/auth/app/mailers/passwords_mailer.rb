# frozen_string_literal: true

class PasswordsMailer < ApplicationMailer
  def reset_email(params)
    @user = User.find_by email_address: params[:email_address]

    return unless @user.present?

    mail subject: "Reset your password", to: @user.email_address
  end
end
