require 'rest_client'

SCHEDULER.every "30m" do
  response = RestClient.get "https://X:#{ENV["GEMNASIUM_TOKEN"]}@api.gemnasium.com/v1/projects"
  results = JSON.parse(response.to_str)
  colours = results["owned"].select do |result|
    result["monitored"]
  end.map do |monitored|
    monitored["color"]
  end
  reds = colours.select { |colour| colour == "red" }
  if reds.count > 0
    send_event('gemnasium', { current: reds.count, status: 'warning' })
  else
    yellows = colours.select { |colour| colour == "yellow" }
    if yellows.count > 0
      send_event('gemnasium', { current: yellows.count, status: 'danger' })
    else
      send_event('gemnasium', { status: 'ok' })
    end
  end
end
