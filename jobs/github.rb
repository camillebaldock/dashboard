require 'octokit'

SCHEDULER.every "30m" do
  Octokit.auto_paginate = true
  client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  assigned = client.user_issues(:state => "open", :filter => "assigned").length
  created = client.user_issues(:state => "open", :filter => "created").length
  send_event("github-issues", { current: assigned + created })
end
