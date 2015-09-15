require "json"
require "uri"
require "net/http"

key="rss"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    headers = {
      "Authorization" => "OAuth #{ENV["FEEDLY_TOKEN"]}"
    }
    uri = URI.parse("http://cloud.feedly.com/v3/markers/counts")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.get(uri.path, headers)
    response_hash = JSON.parse(response.body)
    unread_counts = response_hash["unreadcounts"]
    reading_count = unread_counts.find do |unread_count|
      unread_count["id"].include?("category/Reading")
    end
    rss_count = reading_count["count"]

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(rss_count)
    send_event(key, { "current" => rss_count, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
