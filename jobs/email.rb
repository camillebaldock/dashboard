require 'gmail'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("email")
  logger.start
  begin
    Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"]) do |gmail|
      inbox_count = gmail.inbox.count
      if inbox_count == 0
        status = 'ok'
      elsif inbox_count < 5
        status = 'attention'
      elsif inbox_count < 10
        status = 'warning'
      else
        status = 'danger'
      end
      send_event("email", { current: inbox_count, status: status })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
