require 'mechanize'

key="ancestry"
config = ConfigRepository.new(key)

ANCESTRY_LOGIN_PAGE = "http://www.ancestry.co.uk"
SIGNIN_FORM_IDENTIFIER = "signInForm"

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    @mechanize_agent = Mechanize.new
    @mechanize_agent.user_agent_alias = 'Windows Mozilla'
    @mechanize_agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    signin_page = @mechanize_agent.get(ANCESTRY_LOGIN_PAGE)
    signin_form = signin_page.forms[0]
    signin_form.username = ENV["ANCESTRY_EMAIL"]
    signin_form.password = ENV["ANCESTRY_PASSWORD"]

    logged_in_page = @mechanize_agent.submit(signin_form)
    hints_link = logged_in_page.at("#navHints").attributes['href']
    hints_page = @mechanize_agent.get(hints_link)
    hint_text = hints_page.at("#subNav1").text
    hints_number = hint_text.match(/\w*\((\d*)\)/)
    nb_hints = hints_number[1].to_i

    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(nb_hints)
    send_event(key, { "current" => nb_hints, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
