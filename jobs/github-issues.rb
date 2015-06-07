require 'octokit'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("github-issues")
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    assigned_ids = client.user_issues(:state => "open", :filter => "assigned").map(&:id)
    created_ids = client.user_issues(:state => "open", :filter => "created").map(&:id)
    all_issue_ids = (assigned_ids + created_ids).uniq
    send_event("github-issues", { current: all_issue_ids.count })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
