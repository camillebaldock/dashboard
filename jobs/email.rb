require 'gmail'

SCHEDULER.every "30m" do
  Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"]) do |gmail|
    send_event("email", { current: gmail.inbox.count })
  end
end
