require 'octokit'

SCHEDULER.every "#{ENV["UPDATE_FREQUENCY"]}" do
  Octokit.auto_paginate = true
  client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  assigned = client.user_issues(:state => "open", :filter => "assigned").length
  created = client.user_issues(:state => "open", :filter => "created").length
  mentioned = client.user_issues(:state => "open", :filter => "mentioned").length
  send_event("github-issues", { current: assigned + created + mentioned })
end
