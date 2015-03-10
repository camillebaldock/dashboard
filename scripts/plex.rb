require 'plex-ruby'
require 'json'

server = Plex::Server.new(ENV["SERVER_HOST"], 32400)
sections = server.library.sections
tv_shows_section = sections.find{|section| section.title == "TV Shows" }
tv_shows = tv_shows_section.all
unwatched_tv_shows = 0
tv_shows.each do |tv_show|
  unwatched_tv_shows += tv_show.leaf_count.to_i - tv_show.viewed_leaf_count.to_i
end
films_section = sections.find{|section| section.title == "Movies" }
unwatched_films = films_section.unwatched.count
videos_section = sections.find{|section| section.title == "Home Videos" }
unwatched_videos = videos_section.unwatched.count

auth_token=ENV["AUTH_TOKEN"]

json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

p "#{unwatched_tv_shows} TV shows"
p "#{unwatched_films} movies"
p "#{unwatched_videos} videos"
params = {'auth_token' => auth_token, 'current' => unwatched_tv_shows}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/tv')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)

params = {'auth_token' => auth_token, 'current' => unwatched_films}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/films')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)

params = {'auth_token' => auth_token, 'current' => unwatched_videos}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/videos')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)
