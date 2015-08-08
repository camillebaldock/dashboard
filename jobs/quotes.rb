require 'mechanize'
require 'json'

SCHEDULER.every "1m", :first_in => 0 do
  logger = Logger.new("quotes")
  logger.start
  begin
    quote_documents = YAML.load(File.open("./quotes.yml"))
    quotes = []
    quote_documents.each do |quote_document|
      entry = quote_document.values.first
      entry["quotes"].each do |quote|
        quotes << {
          author: entry["author"],
          title: entry["title"],
          text: quote
        }
      end
    end
    quote = quotes.sample
    send_event("quotes", { text: quote[:text], title: quote[:title], author: quote[:author] } )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
