cd /Users/camillebaldock/Code/Quantified/dashboard
echo "Starting"
source environment.sh
bundle exec ruby scripts/plex.rb
bundle exec ruby scripts/pocket_casts.rb
echo "Export over"
