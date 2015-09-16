require 'gmail'

key="email"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    inbox_count = 0
    Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"]) do |gmail|
      inbox_count = gmail.inbox.count
    end

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(inbox_count)
    send_event(key, { "current" => inbox_count, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
