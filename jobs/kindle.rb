require 'mechanize'
require 'json'

KINDLE_LOGIN_PAGE      = "http://kindle.amazon.com/login"
SIGNIN_FORM_IDENTIFIER = "signIn"

class KindleClient
  #Code taken from https://github.com/speric/kindle-highlights
  #some modifications made to differentiate read status
  attr_reader :books, :to_read

  def initialize(email_address, password)
    @email_address = email_address
    @password      = password
    @books         = Hash.new
    @to_read       = 0

    setup_mechanize_agent
    load_books_from_kindle_account
  end

  def highlights_for(asin)
    highlights = @mechanize_agent.get("https://kindle.amazon.com/kcw/highlights?asin=#{asin}&cursor=0&count=1000")
    json = JSON.parse(highlights.body)
    json["items"]
  end

  def highlights
    result = []
    @books.each do |book_key, value|
      highlights = highlights_for(book_key)
      highlights.each do |highlight|
        result << {:text => highlight[:highlight], :title => value}
      end
    end
    result
  end

  private

  def load_books_from_kindle_account
    signin_page = @mechanize_agent.get(KINDLE_LOGIN_PAGE)

    signin_form = signin_page.form(SIGNIN_FORM_IDENTIFIER)
    signin_form.email = @email_address
    signin_form.password = @password

    kindle_logged_in_page = @mechanize_agent.submit(signin_form)
    highlights_page = @mechanize_agent.click(kindle_logged_in_page.link_with(text: /Your Books/))

    loop do
      highlights_page.search(".//tr")[1..-1].each do |book|
        title_and_author = book.search(".titleAndAuthor").first
        status = book.search(".statusText").first
        asin_and_title_element = title_and_author.search("a").first
        asin = asin_and_title_element.attributes["href"].value.split("/").last
        title = asin_and_title_element.inner_html
        to_read = status.search("div")[2].children.text == "Hope to Read "
        @books[asin] = title
        if to_read
          @to_read +=1
        end
      end
      break if highlights_page.link_with(text: /Next/).nil?
      highlights_page = @mechanize_agent.click(highlights_page.link_with(text: /Next/))
    end
  end

  def setup_mechanize_agent
    @mechanize_agent = Mechanize.new
    @mechanize_agent.user_agent_alias = 'Windows Mozilla'
    @mechanize_agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

SCHEDULER.every "30m" do
  logger = Logger.new("kindle")
  logger.start
  begin
    client = KindleClient.new(ENV["AMAZON_EMAIL"], ENV["AMAZON_PASSWORD"])
    send_event("kindle", { current: client.to_read })
    highlight = client.highlights.sample
    send_event("quotes", { quote: highlight[:text], more_info: highlight[:title] })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
