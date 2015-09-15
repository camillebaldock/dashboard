require 'mechanize'
require 'json'

key="kindle"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, :first_in => 0 do
  logger = Logger.new(key)
  logger.start
  begin
    client = KindleClient.new(ENV["AMAZON_EMAIL"], ENV["AMAZON_PASSWORD"])
    kindle = client.to_read

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(kindle)
    send_event(key, { "current" => kindle, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
