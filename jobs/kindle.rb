require 'mechanize'
require 'json'

SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("kindle")
  logger.start
  begin
    client = KindleClient.new(ENV["AMAZON_EMAIL"], ENV["AMAZON_PASSWORD"])
    send_event("kindle", { current: client.to_read })
    highlights = client.highlight
    highlight = highlights.sample
    send_event("quotes", { text: highlight[:text] } )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
