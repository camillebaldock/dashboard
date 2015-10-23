require 'open-uri'
require 'nokogiri'

key="books"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    url = "https://www.goodreads.com/review/list/#{ENV["GOODREADS_LIST_ID"]}.xml?key=#{ENV["GOODREADS_KEY"]}&shelf=fiction-to-read&v=2"
    doc = Nokogiri::XML(open(url))
    books = doc.xpath("//reviews").attr('total').value.to_i

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(books)
    send_event(key, { "current" => books, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
