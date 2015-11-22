class ColourCalculator

  def initialize(config_repository)
    @settings = config_repository.settings
    @goal = @settings["goal"]
    @colour = @settings["colour"]
  end

  def get_colour(number)
    if @goal && @settings["increase"]=="true"
      get_increasing_status(number)
    elsif @goal
      get_status(number)
    else
      @colour
    end
  end

  private

  def get_status(number)
    lower_limits = @goal.values.select{ |limit| limit <= number }
    if lower_limits.empty?
      "#2EFE2E"
    else
      largest_lower_limit = lower_limits.max
      @goal.key(largest_lower_limit)
    end
  end

  def get_increasing_status(number)
    higher_limits = @goal.values.select{ |limit| limit >= number }
    if higher_limits.empty?
      "#2EFE2E"
    else
      smaller_higher_limit = higher_limits.min
      @goal.key(smaller_higher_limit)
    end
  end

end
