require 'net/https'
require 'json'

key="travis"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, :first_in => 0 do
  logger = Logger.new(key)
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

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(broken_builds)
    if broken_builds > 0
      send_event(key, { current: broken_builds, "background-color" => colour })
    else
      send_event(key, { current: "ok", "background-color" => colour })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
