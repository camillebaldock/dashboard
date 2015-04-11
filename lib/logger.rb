require 'redis'

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
    Redis.current.set("date_#{@name}", DateTime.now.strftime("%m/%d/%Y at %I:%M%p"))
    p "**JOB** #{@name}: finished"
  end
end
