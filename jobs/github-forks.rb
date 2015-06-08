require 'octokit'

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("github-forks")
  logger.start
  begin
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
    number_prs = 0
    repos = client.repositories(:user => ENV["GITHUB_USER"])
    forks = repos.select do |repo|
      repo.fork
    end
    out_of_date_forks = []
    forks.each do |fork|
      if fork.full_name.include?(ENV["GITHUB_USER"])
        parent = client.repository("#{ENV["GITHUB_USER"]}/#{fork.name}").parent
        parent_commits = parent.rels[:commits].get.data
        latest_parent_commit_date = parent_commits.first.commit.committer.date
        latest_parent_commit_sha = parent_commits.first.sha
        repo_commits = fork.rels[:commits].get.data
        while repo_commits.last.commit.committer.date > latest_parent_commit_date do
          repo_commits = client.last_response.rels[:next].get.data
        end
        repo_shas = repo_commits.map(&:sha)
        unless repo_shas.index(latest_parent_commit_sha)
          out_of_date_forks << fork.name
        end
      end
    end
    formatted_forks = {"items" => []}
    out_of_date_forks.each do |out_of_date_fork|
      hash = {"label" => out_of_date_fork}
      formatted_forks["items"] << hash
    end
    settings = {
      "danger" => 1
    }
    status_calculator = StatusCalculator.new(settings)
    status = status_calculator.run(formatted_forks["items"].count)
    send_event("github-forks", formatted_forks, status: status)
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
