require 'uri'
require 'net/http'
require 'json'
require 'mechanize'

mechanize = Mechanize.new
page = mechanize.get('https://projecteuler.net/sign_in')
mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
form = page.forms.first
form['username']=ENV['PROJECT_EULER_USERNAME']
form['password']=ENV['PROJECT_EULER_PASSWORD']
button = form.buttons.first
page = form.submit(button)
progress = page.link_with(text: 'Progress')
page = progress.click
solved_string = page.at('#progress_bar_section > h3').text
matches = /Solved (\d+) out of (\d+) problems/.match(solved_string)
euler_left = matches[2].to_i-matches[1].to_i

auth_token=ENV["AUTH_TOKEN"]

json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

params = {'auth_token' => auth_token, 'current' => euler_left}
uri = URI.parse('http://dashboard.camillebaldock.com/widgets/euler')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)

url = URI.parse("http://dashboard.camillebaldock.com/last_updated/euler/#{auth_token}")
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}
