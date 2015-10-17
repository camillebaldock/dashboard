require 'watir-webdriver'
require 'json'
require 'uri'
require 'net/http'
require_relative '../lib/colour_calculator'
require_relative '../lib/config_repository'
Selenium::WebDriver::Firefox::Binary.path=ENV["FIREFOX_PATH"]

class PocketCastsClient

  def initialize(email_address, password)
    @email_address     = email_address
    @password          = password
    @browser           = Watir::Browser.new :firefox
    @unplayed_podcasts = {}
  end

  def podcasts
    @browser.goto "https://play.pocketcasts.com/users/sign_in"
    @browser.text_field(:name => 'user[email]').set(@email_address)
    @browser.text_field(:name => 'user[password]').set(@password)
    @browser.form(:id, 'new_user').submit
    #load home page
    sleep(10)
    podcast_elements = @browser.elements(:class => 'podcast_content').select{ |element| element.visible? }
    podcast_elements.each do |podcast_element|
      process_podcast(podcast_element)
    end
    @browser.close
    @unplayed_podcasts
  end

private

  def process_podcast(podcast_element)
    podcast_element.click
    #load podcast page
    sleep(10)
    name = @browser.elements(:id => 'podcast_header_text').first.h1.text
    show_more = get_visible_show_more_elements
    while show_more.size > 0
      #load more entries
      sleep(10)
      if show_more.first.visible?
        show_more.first.click
      end
      show_more = []
    end
    unplayed = @browser.elements(:class => 'played_status_0').size + @browser.elements(:class => 'played_status_1').size
    p "#{name}: #{unplayed} unplayed"
    @unplayed_podcasts[name] = unplayed
  end

  def get_visible_show_more_elements
    @browser.elements(:class => 'show_more').select{ |element| element.visible? }
  end

end

client = PocketCastsClient.new(ENV["POCKET_CASTS_EMAIL"], ENV["POCKET_CASTS_PASSWORD"])

auth_token=ENV["AUTH_TOKEN"]

json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

unplayed_podcasts = client.podcasts.values.inject(:+)

p "#{unplayed_podcasts} podcasts"
config = ConfigRepository.new("podcasts")
colour_calculator = ColourCalculator.new(config)
colour = colour_calculator.get_colour(unplayed_podcasts)
params = {'auth_token' => auth_token, 'current' => unplayed_podcasts, "background-color" => colour }

uri = URI.parse('http://dashboard.camillebaldock.com/widgets/podcasts')
http = Net::HTTP.new(uri.host, uri.port)
response = http.post(uri.path, params.to_json, json_headers)

url = URI.parse("http://dashboard.camillebaldock.com/last_updated/podcasts/#{auth_token}")
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}
