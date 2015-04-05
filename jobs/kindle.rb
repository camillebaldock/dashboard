require 'mechanize'
require 'json'

SCHEDULER.every "30m" do
  logger = Logger.new("kindle")
  logger.start
  begin
    client = KindleClient.new(ENV["AMAZON_EMAIL"], ENV["AMAZON_PASSWORD"])
    send_event("kindle", { current: client.to_read })
    highlight = client.highlight
    send_event("quotes", { quote: highlight[:text], more_info: highlight[:title] })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
