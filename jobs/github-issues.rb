require 'octokit'

key="github-issues"
config = ConfigRepository.new(key)

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    number_issues = 0

    ENV["MONITORED_GITHUB_ORGS"].split(",").each do |monitored_github_org|
      org_repos = client.organization_repositories(monitored_github_org).map { |repo| repo.name }
      org_repos.each do |org_repo|
        begin
          issues = client.issues("#{monitored_github_org}/#{org_repo}", :state => 'open')
          number_issues += issues.count
        rescue Exception => e
          logger.info(e)
        end
      end
    end

    repos = client.repositories(:user => ENV["GITHUB_USER"])
    user_repos = repos.select do |repo|
      repo.owner.login == ENV["GITHUB_USER"]
    end
    user_repos.each do |user_repo|
      issues = client.issues(ENV["GITHUB_USER"]+"/"+user_repo.name, :state => 'open')
      number_issues += issues.count
    end

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(number_issues)
    send_event(key, { "current" => number_issues, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
