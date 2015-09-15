require 'json'

class ConfigRepository
  def initialize(key, config_folder="data")
    @config = get_config(key, config_folder)
  end

  def settings
    @config.fetch("settings")
  end

  def frequency
    @config.fetch("frequency")
  end

  private

  def get_config(key, config_folder)
    config_values = {}
    Dir["#{config_folder}/*.json"].each do |json_file|
      file = File.read(json_file)
      config_values = config_values.merge(JSON.parse(file))
    end
    config_values.fetch(key)
  end
end
