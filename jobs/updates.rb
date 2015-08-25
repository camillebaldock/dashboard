require 'date'

def calculate_color(number_string, settings)
  status_calculator = StatusCalculator.new(settings)
  status_calculator.get_color(number_string.to_i)
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
    laptop_settings = {
      "danger" => 60,
      "warning" => 90
    }
    blog_settings = {
      "danger" => 30,
      "warning" => 60
    }
    newsletter_settings = {
      "danger" => 30,
      "warning" => 60
    }
    formatted_updates = {}
    update_document.each do |update_entry, update_value|
      formatted_updates[update_entry] = {
        "ago" => days_ago(update_value),
        "number_days" => number_days(update_value)
      }
    end
    p formatted_updates
    send_event("laptop", {
        "text" => formatted_updates["laptop"]["ago"],
        "background-color" => calculate_color(formatted_updates["laptop"]["number_days"], laptop_settings)
      }
    )
    send_event("blog", {
        "text" => formatted_updates["blog"]["ago"],
        "background-color" => calculate_color(formatted_updates["blog"]["number_days"], blog_settings)
      }
    )
    send_event("newsletter", {
        "text" => formatted_updates["newsletter"]["ago"],
        "background-color" => calculate_color(formatted_updates["newsletter"]["number_days"], newsletter_settings)
      }
    )
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
