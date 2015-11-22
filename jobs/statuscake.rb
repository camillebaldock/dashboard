require 'json'

username = ENV["STATUSCAKE_USERNAME"]
secret_key = ENV["STATUSCAKE_KEY"]
key="statuscake"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    items=[]
    is_down=0
    status='ok'
    response = Net::HTTP.get_response(URI('https://www.statuscake.com/API/Tests/?Username='+username+'&API='+secret_key))
    all_tests = JSON.parse(response.body)
    test_ids = all_tests.map do |site_test|
      site_test["TestID"]
    end
    test_ids.each do |testid|
      response = Net::HTTP.get_response(URI("https://www.statuscake.com/API/Tests/Details/?TestID=#{testid}&Username=#{username}&API=#{secret_key}"))
      website = JSON.parse(response.body)
      if website['Status']!='Up'
        items << { site: website['WebsiteName'], status: website['Status'], lasttest: website['LastTested'] }
        status='warning'
      end
    end
    if items.count > 0
      send_event(key, { "current" => items.count, "background-color" => 'red' })
    else
      send_event(key, { "current" => "ok", "background-color" => '#2EFE2E' })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
