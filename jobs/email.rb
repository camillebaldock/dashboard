require 'gmail'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("email")
  logger.start
  begin
    Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"]) do |gmail|
      inbox_count = gmail.inbox.count
      settings = {
        "attention" => 1,
        "danger" => 5,
        "warning" => 10
      }
      status_calculator = StatusCalculator.new(settings)
      status = status_calculator.run(inbox_count)
      send_event("email", { current: inbox_count, status: status })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
