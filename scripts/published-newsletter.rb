require 'uri'
require 'net/http'
require 'json'

auth_token=ENV["AUTH_TOKEN"]
last_newsletter='15 November 2014'

json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

params = {'auth_token' => auth_token, 'since_date' => last_newsletter, 'red_after' => 30}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/newsletter')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)

url = URI.parse("http://dashboard.camillebaldock.com/last_updated/newsletter/#{auth_token}")
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}
