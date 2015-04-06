require 'net/https'
require 'json'

rescuetime_api_key = ENV["RESCUETIME_KEY"]

SCHEDULER.every '1h', :first_in => 0 do |job|
  logger = Logger.new("rescuetime")
  logger.start
  begin
    http = Net::HTTP.new("www.rescuetime.com", 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    today = Date.today.to_s
    seven_days_ago = Date.today - 7*24
    #gets the data for today broken by productivity (very distracting, distracting, neutral, etc)
    #see https://www.rescuetime.com/anapi/setup/documentation for other options
    response = http.request(Net::HTTP::Get.new("/anapi/data?key=#{rescuetime_api_key}&format=json&restrict_begin=#{seven_days_ago.to_s}&restrict_end=#{today}"))
    usage = JSON.parse(response.body)

    data = {
      very_productive: 0,
      productive: 0,
      neutral: 0,
      unproductive: 0,
      very_unproductive: 0
    }
    usage["rows"].each do |row|
      data[:very_productive] += row[1] if row[5]==2
      data[:productive] += row[1] if row[5]==1
      data[:neutral] += row[1] if row[5]==0
      data[:unproductive] += row[1] if row[5]==-1
      data[:very_unproductive] += row[1] if row[5]==-2
    end
    productive = data[:very_productive]+data[:productive]
    unproductive = data[:neutral] + data[:unproductive] + data[:very_unproductive]
    percentage_prod = productive/(productive+unproductive) * 100

    send_event("rescuetime", { current: "#{percentage_prod}%"})

  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
