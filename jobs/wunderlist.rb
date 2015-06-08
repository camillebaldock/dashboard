require 'rest_client'
require 'date'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("wunderlist")
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
    settings = {
      "attention" => 1,
      "danger" => 3,
      "warning" => 6
    }
    status_calculator = StatusCalculator.new(settings)
    status = status_calculator.run(total)
    send_event('wunderlist', { current: total, status: status })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
