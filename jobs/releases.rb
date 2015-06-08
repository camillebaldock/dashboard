require 'octokit'

SCHEDULER.every "1h", first_in: 0 do
  logger = Logger.new("releases")
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
    settings = {
      "danger" => 1
    }
    status_calculator = StatusCalculator.new(settings)
    status = status_calculator.run(formatted_releases["items"].count)
    send_event("releases", formatted_releases, status: status)
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
