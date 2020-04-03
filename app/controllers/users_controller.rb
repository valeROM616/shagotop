class BotControllerError < StandardError; end
class ApiController < ActionController::Base
  # protect_from_forgery with: :null_session
end
class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  # protect_from_forgery prepend: false
  # protect_from_forgery with: :null_session
  # skip_forgery_protection true
  #
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

  def update

  end

  def create
    # echo "hi"
    # render plain: "bdc2d588"
    # sender(Main.confirmation)
    # obj = JSON.parse(params)

    # if params[:type] == "confirmation"
    #   sender(Main.confirmation)
    # elsif params[:type] == 'message_new'
    #   sender(Main.send_message(params))
    # else
    #   sender('What the fuck')
    # end
    # return 'ok'
    # render plain: 'ok'
  end

  def sender(content)
    render plain: 'ok'
  end

end

