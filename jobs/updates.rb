require 'date'

def calculate_color(number_string, settings)
  colour_calculator = ColourCalculator.new(settings)
  colour_calculator.get_colour(number_string.to_i)
end

def days_ago(date_string)
  number_days = (Date.today - Date.parse(date_string)).to_i
  if number_days < 1
    "less than 1 day ago"
  elsif number_days == 1
    "1 day ago"
  elsif number_days <30
    "#{number_days} days ago"
  elsif number_days < 60
    "1 month ago"
  elsif number_days < 365
    "#{number_days/30} months ago"
  else
    "more than 1 year ago"
  end
end

def number_days(date_string)
  (Date.today - Date.parse(date_string)).to_i
end

SCHEDULER.every "1h", :first_in => 0 do
  logger = Logger.new("updates")
  logger.start
  begin
    update_document = YAML.load(File.open("./data/updates.yml"))
    formatted_updates = {}
    update_document.each do |update_entry, update_value|
      formatted_updates[update_entry] = {
        "ago" => days_ago(update_value),
        "number_days" => number_days(update_value)
      }
    end
    blog_config = ConfigRepository.new("blog")
    send_event("blog", {
        "text" => formatted_updates["blog"]["ago"],
        "background-color" => calculate_color(formatted_updates["blog"]["number_days"], blog_config)
      }
    )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
