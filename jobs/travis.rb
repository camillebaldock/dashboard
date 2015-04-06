SCHEDULER.every "30m" do
  logger = Logger.new("travis")
  logger.start
  begin
    send_event('travis', { current: 0 })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
