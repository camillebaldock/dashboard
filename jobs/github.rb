require 'octokit'

SCHEDULER.every '10m' do
  client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  user = client.user
  repos = user.rels["repos"].get.data
  issues = repos.map(&:open_issues).reduce(:+)
  send_event("github-issues", { current: issues })
end
