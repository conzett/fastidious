# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]

  def new; end

  def create
    @user = User.new user_params

    if @user.save
      render :show, status: :created, location: user_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect user: %i[email_address password password_confirmation]
  end
  
  def user_url
    request.format.html? ? new_session_url : super
  end
end
