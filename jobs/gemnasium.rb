require 'rest_client'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("gemnasium")
  logger.start
  begin
    response = RestClient.get "https://X:#{ENV["GEMNASIUM_TOKEN"]}@api.gemnasium.com/v1/projects"
    results = JSON.parse(response.to_str)
    colours = results["owned"].select do |result|
      result["monitored"]
    end.map do |monitored|
      monitored["color"]
    end
    reds = colours.select { |colour| colour == "red" }
    if reds.count > 0
      send_event('gemnasium', { current: reds.count, "background-color" => 'red' })
    else
      yellows = colours.select { |colour| colour == "yellow" }
      if yellows.count > 0
        send_event('gemnasium', { current: yellows.count, "background-color" => 'yellow' })
      else
        send_event('gemnasium', { "background-color" => 'green' })
      end
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
