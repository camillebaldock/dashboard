require 'gmail'

SCHEDULER.every "#{ENV["UPDATE_FREQUENCY"]}" do
  Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"]) do |gmail|
    send_event("email", { current: gmail.inbox.count })
  end
end
