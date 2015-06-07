require 'open-uri'
require 'nokogiri'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("books")
  logger.start
  begin
    url = "https://www.goodreads.com/review/list/#{ENV["GOODREADS_LIST_ID"]}.xml?key=#{ENV["GOODREADS_KEY"]}&v=2"
    doc = Nokogiri::XML(open(url))
    send_event("books", { current: doc.xpath("//reviews").attr('total').value })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
