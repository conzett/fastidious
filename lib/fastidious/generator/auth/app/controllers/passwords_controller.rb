# frozen_string_literal: true

class PasswordsController < UsersController
  skip_before_action :require_authentication, only: %i[edit update]

  before_action :set_user, only: %i[edit update]

  def edit; end

  # TODO: Error messages for model

  def update
    if @user.update user_params
      render :show, location: new_session_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect user: %i[password password_confirmation]
  end

  # TODO: Rescue and handle error message

  def set_user
    @user = User.find_by_password_reset_token! params[:token]
  end
end
