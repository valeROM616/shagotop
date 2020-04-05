set :output, "/home/valerom/chat-bot-api/cron_log.log"

every 1.day, at: '9:00pm' do
  runner 'Main.users_to_send'
end
