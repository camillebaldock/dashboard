require 'octokit'

key="releases"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    file = client.contents(ENV["BOXEN_REPO"], :path => 'Puppetfile.lock')
    content = Base64.decode64(file['content'])
    parser = PuppetfileLockParser.new(content)
    releases = parser.releases
    formatted_releases = { "items" => [] }
    releases.each do |release_key, release_value|
      unless release_key.include?(ENV["GITHUB_USER"])
        package = release_key.match(/.*\/puppet-(.*)/)
        unless package
          package = release_key.match(/.*\/(.*)/)
        end
        new_release = client.releases(release_key)
        unless new_release.empty?
          new_release_value = new_release.first.tag_name
          if new_release_value.gsub(".","").to_i > release_value.gsub(".","").to_i
            hash = {"label" => package[1], "value" => "#{release_value} --> #{new_release_value}"}
          end
        end
        formatted_releases["items"] << hash
      end
    end
    formatted_releases["items"].compact!

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(formatted_releases["items"].count)
    formatted_releases["background-color"] = colour
    send_event(key, formatted_releases)
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
