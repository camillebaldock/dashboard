require 'watir-webdriver'
Selenium::WebDriver::Firefox::Binary.path=ENV["FIREFOX_PATH"]

class GoWatchItClient

  def initialize(user, password)
    @user     = user
    @password = password
    @browser  = Watir::Browser.new :firefox
  end

  def number_in_queue
    @browser.goto "http://gowatchit.com/users/sign_in"
    @browser.text_field(:name => 'user[email]').set(@user)
    @browser.text_field(:name => 'user[password]').set(@password)
    @browser.element(:css => '#login').click
    sleep 5
    number = @browser.element(:css => "#movie_count").text.to_i
    @browser.close
    number
  end

end

client = GoWatchItClient.new(ENV["GO_WATCH_IT_USER"], ENV["GO_WATCH_IT_PASSWORD"])

auth_token=ENV["AUTH_TOKEN"]

json_headers = {"Content-Type" => "application/json",
              "Accept" => "application/json"}

number = client.number_in_queue

p "#{number} films"
params = {'auth_token' => auth_token, 'current' => number }

uri = URI.parse('http://dashboard.camillebaldock.com/widgets/go_watch_it')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)
