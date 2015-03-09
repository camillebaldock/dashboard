require 'uri'
require 'net/http'
require 'json'

auth_token=ENV["AUTH_TOKEN"]
last_post='10 September 2014'

json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

params = {'auth_token' => auth_token, 'since_date' => last_post, 'red_after' => 45}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/blog')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)
