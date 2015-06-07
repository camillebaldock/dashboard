require 'net/http'
require 'json'

placeholder = '/assets/puppy.jpg'

SCHEDULER.every '10m', :first_in => 0 do |job|
  logger = Logger.new("randomaww")
  logger.start
  begin
    http = Net::HTTP.new('www.reddit.com')
    response = http.request(Net::HTTP::Get.new("/r/aww.json"))
    json = JSON.parse(response.body)

    if json['data']['children'].count <= 0
      send_event('aww', image: placeholder)
    else
      urls = json['data']['children'].map{|child| child['data']['url'] }
      # Ensure we're linking directly to an image, not a gallery etc.
      valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
      random_aww = valid_urls.sample
      send_event('aww', image: random_aww)
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
