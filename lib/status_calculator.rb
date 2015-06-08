class StatusCalculator

  def initialize(settings)
    @settings = settings
    @limits = settings.values.sort
  end

  def run(number)
    lower_limits = @limits.select{ |limit| limit <= number }
    if lower_limits.empty?
      "ok"
    else
      largest_lower_limit = lower_limits.max
      @settings.key(largest_lower_limit)
    end
  end

end
