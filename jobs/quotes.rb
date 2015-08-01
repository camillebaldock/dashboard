require 'mechanize'
require 'json'

SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("quotes")
  logger.start
  begin
    quote_documents = YAML.load(File.open("./quotes.yml"))
    quotes = quote_documents.first.values.first["quotes"]
    send_event("quotes", { text: quotes.sample } )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
