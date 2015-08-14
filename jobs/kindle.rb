require 'mechanize'
require 'json'

SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("kindle")
  logger.start
  begin
    client = KindleClient.new(ENV["AMAZON_EMAIL"], ENV["AMAZON_PASSWORD"])
    kindle = client.to_read
    settings = {
      "danger" => 10
    }
    status_calculator = StatusCalculator.new(settings)
    color = status_calculator.get_color(kindle)
    send_event("kindle", { "current" => kindle, "background-color" => color })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
