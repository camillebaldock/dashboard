require "mechanize"

KINDLE_LOGIN_PAGE      = "http://kindle.amazon.com/login"
SIGNIN_FORM_IDENTIFIER = "signIn"

class KindleClient
  attr_reader :to_read

  def initialize(email_address, password)
    @email_address = email_address
    @password      = password
    @to_read       = 0

    setup_mechanize_agent
    load_books_from_kindle_account
  end

  private

  def load_books_from_kindle_account
    signin_page = @mechanize_agent.get(KINDLE_LOGIN_PAGE)

    signin_form = signin_page.form(SIGNIN_FORM_IDENTIFIER)
    signin_form.email = @email_address
    signin_form.password = @password

    kindle_logged_in_page = @mechanize_agent.submit(signin_form)
    your_books_page = @mechanize_agent.click(kindle_logged_in_page.link_with(text: /Your Books/))
    @to_read=your_books_page.at("//*[@id='readingListCount3']").text.to_i
  end

  def setup_mechanize_agent
    @mechanize_agent = Mechanize.new
    @mechanize_agent.user_agent_alias = 'Windows Mozilla'
    @mechanize_agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end
