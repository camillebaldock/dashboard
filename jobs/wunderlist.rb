require 'rest_client'
require 'date'

key="wunderlist"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    headers = {
      "X-Access-Token" => ENV["WUNDERLIST_CLIENT_TOKEN"],
      "X-Client-ID" => ENV["WUNDERLIST_CLIENT_ID"]
    }
    lists_response = RestClient.get "https://a.wunderlist.com/api/v1/lists", headers
    lists_hash = JSON.parse(lists_response.to_str)
    list_ids = lists_hash.map do |list|
      list["id"]
    end
    total = 0
    list_ids.each do |list_id|
      tasks_response = RestClient.get "https://a.wunderlist.com/api/v1/tasks?list_id=#{list_id}", headers
      tasks = JSON.parse(tasks_response.to_str)
      due_tasks = tasks.select do |task|
        task["due_date"] && Date.parse(task["due_date"]) <= Date.today
      end
      total += due_tasks.count
    end

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(total)

    send_event(key, { "current" => total, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
