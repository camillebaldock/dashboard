require 'rest_client'

key="gemnasium"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
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
      send_event(key, { current: reds.count, "background-color" => 'red' })
    else
      yellows = colours.select { |colour| colour == "yellow" }
      if yellows.count > 0
        send_event(key, { current: yellows.count, "background-color" => 'orange' })
      else
        send_event(key, { "current" => "ok", "background-color" => '#2EFE2E' })
      end
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
