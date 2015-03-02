require 'net/https'
require 'json'

######################### CONFIGURATION START #########################
# RescueTime API Key from https://www.rescuetime.com/anapi/setup_submit
ENV["RESCUETIME_KEY"] = "B63TChEx7XtQwzpeUBXVfe2QHtWOFbyLaXC0JpaM"
rescuetime_api_key = ENV["RESCUETIME_KEY"]
p rescuetime_api_key
goals = {
  total_productive: 7*60, #minutes, equal or greater to
  total_unproductive: 3*60, #minutes, less than
}
hours_to_analyze = nil #set to nil if you don't want hour based filtering
######################### CONFIGURATION END ###########################


def pretty_time(seconds)
    return "" if !seconds
    mins = seconds/60
    "#{(mins/60).floor}h#{(mins%60).floor}m"
end

#debugging
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new("www.rescuetime.com", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  #gets the data for today broken by productivity (very distracting, distracting, neutral, etc)
  #see https://www.rescuetime.com/anapi/setup/documentation for other options
  response = http.request(Net::HTTP::Get.new("/anapi/data?key=#{rescuetime_api_key}&format=json&perspective=interval&restrict_kind=productivity"))
  usage = JSON.parse(response.body)

  data = {
    very_productive: 0,
    productive: 0,
    neutral: 0,
    unproductive: 0,
    very_unproductive: 0
  }
  usage["rows"].each do |row|
    if hours_to_analyze
      date = DateTime.parse row[0]
      next unless hours_to_analyze.include? date.hour
    end

    data[:very_productive] += row[1] if row[3]==2
    data[:productive] += row[1] if row[3]==1
    data[:neutral] += row[1] if row[3]==0
    data[:unproductive] += row[1] if row[3]==-1
    data[:very_unproductive] += row[1] if row[3]==-2
  end

  data[:total_productive] = data[:very_productive] + data[:productive]
  data[:total_unproductive] = data[:unproductive] + data[:very_unproductive]

  data.each do |key,seconds|
    minutes = seconds/60
    my_data = { value: minutes, prettyValue: pretty_time(seconds), color: "#00ff00" }

    if goals[key]
      goal = goals[key].to_f

      if key.to_s.include?("unproductive")
        if minutes>goal
          my_data["color"] = "#ff0000"
        elsif minutes/goal >= 0.75
          my_data["color"] = "#E38217"
        elsif minutes/goal >= 0.5
          my_data["color"] = "#ffff00"
        else
          my_data["color"] = "#EEE8AA"
        end
      else
        if minutes/goal >= 0.8
          my_data["color"] = "#00ff00"
        else
          my_data["color"] = "#BCED91"
        end
      end

      if minutes>goal
        my_data["max"] = minutes
      else
        my_data["max"] = goal
      end
    else
      my_data["max"] = 8*60
    end

    if key==:total_productive
      my_data["moreinfo"] = "Very productive: #{pretty_time(data[:very_productive])} Productive: #{pretty_time(data[:productive])}"
    elsif key==:total_unproductive
      my_data["moreinfo"] = "Very unproductive: #{pretty_time(data[:very_unproductive])} Unproductive: #{pretty_time(data[:unproductive])}"
    end

    send_event("rescuetime_#{key}", my_data)
  end
end
