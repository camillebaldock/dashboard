require 'net/https'
require 'json'

SCHEDULER.every "10m", :first_in => 0 do
  logger = Logger.new("travis")
  logger.start
  broken_builds = 0
  begin
    http = Net::HTTP.new("api.travis-ci.org", 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    repos = ENV["TRAVIS_REPOS"].split(",")
    repos.each do |repo|
      response = http.request(Net::HTTP::Get.new("/repositories/#{ENV["GITHUB_USER"]}/#{repo}.json"))
      usage = JSON.parse(response.body)
      if usage["last_build_status"].to_i != 0
        broken_builds += 1
      end
    end
    settings = {
      "warning" => 1
    }
    status_calculator = StatusCalculator.new(settings)
    color = status_calculator.get_color(broken_builds)
    if broken_builds > 0
      send_event('travis', { current: broken_builds, "background-color" => color })
    else
      send_event('travis', { current: nil, "background-color" => color })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
