require 'redis'
require 'json'

class Logger

  def initialize(name)
    @name = name
  end

  def start
    p "**JOB** #{@name}: starting"
  end

  def info(message)
    p "**JOB INFO** #{@name}: #{message}"
  end

  def exception(exception)
    p "**JOB ERROR** #{@name}: #{exception.message}"
  end

  def end
    file = File.read('data/updates.json')
    update_hash = JSON.parse(file)
    update_hash[@name] = DateTime.now.strftime("%m/%d/%Y at %I:%M%p")
    File.open("data/updates.json","w") do |f|
      f.write(update_hash.to_json)
    end
    p "**JOB** #{@name}: finished"
  end
end
