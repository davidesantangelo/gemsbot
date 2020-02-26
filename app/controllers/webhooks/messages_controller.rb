class Webhooks::MessagesController < ApplicationController
  before_action :verify_update

  def create
    Bot.listener(payload: params)

    render json: :ok
  end

  private

  def verify_update
    return if params[:token] == RubygBot::Application.credentials.telegram_bot_token
    render json: {}, status: 401
  end
end
