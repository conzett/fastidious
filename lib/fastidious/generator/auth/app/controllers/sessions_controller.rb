# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  
  before_action :set_session, only: :destroy

  with_options if: -> { response.status < 400 } do
    after_action -> { start_new_session @session.id }, only: :create
    after_action -> { terminate_session }, only: :destroy
  end

  # TODO: Consider rat limiting
  # rate_limit to: 10, within: 3.minutes, only: :create,
  # with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new; end

  def create
    @session = Session.new session_params

    if @session.save
      render :show, status: :created, location: session_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @session.destroy
      head :not_content, location: root_url
    else
      render :show, status: :unprocessable_entity # TODO: HTML?
    end
  end

  private

  def session_params
    params
      .expect(session: %i[email_address password])
      .merge(user_agent: request.user_agent, ip_address: request.remote_ip)
  end
  
  def set_session
    @session = Session.find cookies.signed[:session_id]
  end

  def session_url
    request.format.html? ? after_authentication_url : super
  end
end
