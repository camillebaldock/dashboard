require 'pocket-ruby'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("pocket")
  logger.start
  begin
    Pocket.configure do |config|
      config.consumer_key = ENV["POCKET_CONSUMER_KEY"]
    end
    client = Pocket.client(:access_token => ENV["POCKET_ACCESS_TOKEN"])
    info = client.retrieve(:detailType => :simple, :state => :unread)
    settings = {
      "attention" => 1,
      "danger" => 10,
      "warning" => 20
    }
    status_calculator = StatusCalculator.new(settings)
    color = status_calculator.get_color(info["list"].count)
    send_event("pocket", { "current" => info["list"].count, "background-color" => color })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
