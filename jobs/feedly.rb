require "json"
require "uri"
require "net/http"

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("feedly")
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
    settings = {
      "attention" => 1,
      "danger" => 10,
      "warning" => 20
    }
    status_calculator = StatusCalculator.new(settings)
    status = status_calculator.run(rss_count)
    send_event('rss', { current: rss_count, status: status })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
