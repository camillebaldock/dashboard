require 'octokit'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("github-prs")
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    number_prs = 0
    repos = client.repositories(:user => ENV["GITHUB_USER"])
    user_repos = repos.select do |repo|
      repo.owner.login == ENV["GITHUB_USER"]
    end
    user_repos.each do |user_repo|
      prs = client.pull_requests(ENV["GITHUB_USER"]+"/"+user_repo.name, :state => 'open')
      prs.each do |pr|
        logger.info(pr.title)
      end
      number_prs += prs.count
    end
    settings = {
      "attention" => 1,
      "danger" => 5,
      "warning" => 10
    }
    status_calculator = StatusCalculator.new(settings)
    status = status_calculator.run(number_prs)
    send_event("github-prs", { current: number_prs, status: status })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
