cd /Users/camillebaldock/Code/Quantified/dashboard
echo "Starting"
source environment.sh
/usr/local/bin/bundle exec ruby scripts/plex.rb
/usr/local/bin/bundle exec ruby scripts/pocket_casts.rb
/usr/local/bin/bundle exec ruby scripts/go_watch_it.rb
echo "Export over"
