require 'mechanize'
require 'json'

key="go_watch_it"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, :first_in => 0 do
  logger = Logger.new(key)
  logger.start
  begin
    send_event(key, { "current" => 0 })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
