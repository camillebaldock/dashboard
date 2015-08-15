cd /Users/camillebaldock/Code/Quantified\ Camille/dashboard
echo "Starting"
source environment.sh
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
bundle install
bundle exec ruby scripts/plex.rb
bundle exec ruby scripts/pocket_casts.rb
bundle exec ruby scripts/project_euler.rb
echo "Export over"
