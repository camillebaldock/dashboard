require 'octokit'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("github-prs")
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    number_prs = 0

    ENV["MONITORED_GITHUB_ORGS"].split(",").each do |monitored_github_org|
      org_repos = client.organization_repositories(monitored_github_org).map { |repo| repo.name }
      org_repos.each do |org_repo|
        prs = client.pull_requests("#{monitored_github_org}/#{org_repo}", :state => 'open')
        number_prs += prs.count
      end
    end

    repos = client.repositories(:user => ENV["GITHUB_USER"])
    user_repos = repos.select do |repo|
      repo.owner.login == ENV["GITHUB_USER"]
    end
    user_repos.each do |user_repo|
      prs = client.pull_requests(ENV["GITHUB_USER"]+"/"+user_repo.name, :state => 'open')
      number_prs += prs.count
    end

    settings = {
      "attention" => 1,
      "danger" => 5,
      "warning" => 10
    }
    status_calculator = StatusCalculator.new(settings)
    color = status_calculator.get_color(number_prs)
    send_event("github-prs", { "current" => number_prs, "background-color" => color })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
