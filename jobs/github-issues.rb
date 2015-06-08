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
    issue_count = all_issue_ids.count
    settings = {
      "attention" => 1,
      "danger" => 10,
      "warning" => 50
    }
    status_calculator = StatusCalculator.new(settings)
    status = status_calculator.run(issue_count)
    send_event("github-issues", { current: issue_count, status: status })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
