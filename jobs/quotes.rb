require 'mechanize'
require 'json'

SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("quotes")
  logger.start
  begin
    client = KindleClient.new(ENV["AMAZON_EMAIL"], ENV["AMAZON_PASSWORD"])
    highlights = client.highlight
    highlight = highlights.sample
    logger.info(highlight[:text])
    logger.info(highlight[:title])
    send_event("quotes", { text: highlight[:text], source: highlight[:title] } )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
