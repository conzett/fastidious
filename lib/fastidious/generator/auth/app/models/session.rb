# frozen_string_literal: true

class Session < ApplicationRecord
  attr_accessor :email_address, :password

  belongs_to :user

  # TODO: Validation message for missing user
  # TODO: Validate the ip_address and other stuff?

  before_validation :authenticate_user

  private

  def authenticate_user
    self.user = User.authenticate_by(email_address:, password:)
  end
end
