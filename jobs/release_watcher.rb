require 'octokit'

SCHEDULER.every "1h" do
  Octokit.auto_paginate = true
  client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  parser = PuppetfileLockParser.new(File.join(File.dirname(__FILE__), '..', 'data', 'Puppetfile.lock'))
  releases = parser.releases
  formatted_releases = { "items" => [] }
  releases.each do |release_key, release_value|
    package = release_key.match(/.*\/puppet-(.*)/)
    unless package
      package = release_key.match(/.*\/(.*)/)
    end
    new_release = client.releases(release_key)
    unless new_release.empty?
      new_release_value = new_release.first.tag_name
      if new_release_value != release_value
        hash = {"label" => package[1], "value" => "#{release_value} > #{new_release_value}"}
      end
    end
    formatted_releases["items"] << hash
  end
  send_event("releases", formatted_releases)
end
