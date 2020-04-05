class SendMessageJob < ApplicationJob
  def perform(*args)
    Main.users_to_send
  end
end
