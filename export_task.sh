cd /Users/camillebaldock/Code/Quantified/dashboard
echo "Starting"
source environment.sh
bundle exec ruby scripts/plex.rb
bundle exec ruby scripts/pocket_casts.rb
bundle exec ruby scripts/go_watch_it.rb
echo "Export over"
