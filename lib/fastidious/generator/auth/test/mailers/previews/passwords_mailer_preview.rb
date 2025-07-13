class PasswordsMailerPreview < ActionMailer::Preview
  def reset_email
    PasswordsMailer.reset_email email_address: "one@example.com"
  end
end
