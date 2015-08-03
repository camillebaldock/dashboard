require 'mechanize'
require 'json'

SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("updates")
  logger.start
  begin
    update_document = YAML.load(File.open("./data/updates.yml"))
    send_event("laptop", { since_date: update_document["laptop"] } )
    send_event("blog", { since_date: update_document["blog"] } )
    send_event("newsletter", { since_date: update_document["newsletter"] } )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
