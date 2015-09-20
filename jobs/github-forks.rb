require 'octokit'

key="github-forks"
config = ConfigRepository.new(key)

def is_in_sync(client, parent, fork)
  parent_commits = parent.rels[:commits].get.data
  latest_parent_commit_date = parent_commits.first.commit.committer.date
  latest_parent_commit_sha = parent_commits.first.sha
  repo_commits = fork.rels[:commits].get.data
  while repo_commits.last.commit.committer.date > latest_parent_commit_date do
    if client.last_response.rels[:next]
      repo_commits = client.last_response.rels[:next].get.data
    else
      break
    end
  end
  repo_shas = repo_commits.map(&:sha)
  repo_shas.index(latest_parent_commit_sha)
end

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
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
        unless is_in_sync(client, parent, fork)
          out_of_date_forks << fork.name
        end
      end
    end
    manual_forks = ENV["MANUAL_FORKS"].split(";")
    manual_forks.each do |manual_fork|
      repos = manual_fork.split(",")
      parent = client.repository(repos[0])
      fork = client.repository(repos[1])
      unless is_in_sync(client, parent, fork)
        out_of_date_forks << fork.name
      end
    end
    formatted_forks = {"items" => []}
    out_of_date_forks.each do |out_of_date_fork|
      hash = {"label" => out_of_date_fork}
      formatted_forks["items"] << hash
    end

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(formatted_forks["items"].count)
    formatted_forks["background-color"] = colour
    send_event(key, formatted_forks)
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
