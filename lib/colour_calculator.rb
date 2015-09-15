class ColourCalculator

  def initialize(config_repository)
    settings = config_repository.settings
    @goal = settings["goal"]
    @colour = settings["colour"]
  end

  def get_colour(number)
    if @goal
      get_status(number)
    else
      @colour
    end
  end

  private

  def get_status(number)
    lower_limits = @goal.values.sort.select{ |limit| limit <= number }
    if lower_limits.empty?
      "green"
    else
      largest_lower_limit = lower_limits.max
      @goal.key(largest_lower_limit)
    end
  end

end
