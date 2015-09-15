require 'pocket-ruby'

key="pocket"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    Pocket.configure do |config|
      config.consumer_key = ENV["POCKET_CONSUMER_KEY"]
    end
    client = Pocket.client(:access_token => ENV["POCKET_ACCESS_TOKEN"])
    info = client.retrieve(:detailType => :simple, :state => :unread)
    reading_count = info["list"].count

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(reading_count)
    send_event(key, { "current" => reading_count, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
