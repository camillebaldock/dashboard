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
    p "**JOB** #{@name}: finished"
  end
end
