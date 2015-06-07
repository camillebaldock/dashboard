require 'pocket-ruby'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("pocket")
  logger.start
  begin
    Pocket.configure do |config|
      config.consumer_key = ENV["POCKET_CONSUMER_KEY"]
    end
    client = Pocket.client(:access_token => ENV["POCKET_ACCESS_TOKEN"])
    info = client.retrieve(:detailType => :simple, :state => :unread)
    send_event("pocket", { current: info["list"].count })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
