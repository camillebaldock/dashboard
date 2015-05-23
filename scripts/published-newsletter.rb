require 'uri'
require 'net/http'
require 'json'
require 'date'

auth_token=ENV["AUTH_TOKEN"]
last_newsletter=Date.today

json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

params = {'auth_token' => auth_token, 'since_date' => last_newsletter}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/newsletter')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)

url = URI.parse("http://dashboard.camillebaldock.com/last_updated/newsletter/#{auth_token}")
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}
