SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("updates")
  logger.start
  begin
    update_document = YAML.load(File.open("./data/updates.yml"))
    send_event("laptop", { since_date: update_document["laptop"], red_after: 60*3600*24 } )
    send_event("blog", { since_date: update_document["blog"], red_after: 30*3600*24 } )
    send_event("newsletter", { since_date: update_document["newsletter"], red_after: 30*3600*24 } )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
