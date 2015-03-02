require 'gmail'

SCHEDULER.every "30m" do
  logger = Logger.new("email")
  logger.start
  begin
    Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"]) do |gmail|
      send_event("email", { current: gmail.inbox.count })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
