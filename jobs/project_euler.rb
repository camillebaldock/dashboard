require 'uri'
require 'net/http'
require 'json'
require 'mechanize'

key="euler"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    mechanize = Mechanize.new
    page = mechanize.get('https://projecteuler.net/recent')
    mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    total = page.at('td').text.to_i
    solved_file = File.open("data/number_solved_euler.txt", "rb")
    contents = solved_file.read
    solved = contents.to_i
    unsolved = total - solved

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(unsolved)
    send_event(key, { "current" => unsolved, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
