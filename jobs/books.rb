require 'open-uri'
require 'nokogiri'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("books")
  logger.start
  begin
    url = "https://www.goodreads.com/review/list/#{ENV["GOODREADS_LIST_ID"]}.xml?key=#{ENV["GOODREADS_KEY"]}&v=2"
    doc = Nokogiri::XML(open(url))
    books = doc.xpath("//reviews").attr('total').value
    settings = {
      "danger" => 10
    }
    status_calculator = StatusCalculator.new(settings)
    color = status_calculator.get_color(books.to_i)
    send_event("books", { "current" => books, "background-color" => color })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
