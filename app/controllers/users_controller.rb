class BotControllerError < StandardError; end

class UsersController < ApplicationController
  @@perem = "eto peremennaya"
  def index
    if params[:type] == "confirmation"
      sender(Main.confirmation)
    elsif params[:type] == 'message_new'
      Main.send_message(params)
    else
    end
    sender('ok')
  end

  def sender(content)
    render plain: 'ok'
  end

end

