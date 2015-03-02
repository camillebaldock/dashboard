require 'octokit'

SCHEDULER.every "30m" do
  logger = Logger.new("github-issues")
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    assigned = client.user_issues(:state => "open", :filter => "assigned")
    logger.info(assigned[0])
    created = client.user_issues(:state => "open", :filter => "created")
    send_event("github-issues", { current: assigned.length + created.length })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
