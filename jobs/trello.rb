require 'trello'

include Trello

key="trello"
config = ConfigRepository.new(key)

Trello.configure do |config|
  config.developer_public_key = ENV["TRELLO_DEVELOPER_KEY"]
  config.member_token = ENV["TRELLO_MEMBER_TOKEN"]
end

SCHEDULER.every config.frequency, first_in: 0 do
  logger = Logger.new(key)
  logger.start
  begin
    board = Board.all.find { |board| board.name == ENV["TRELLO_BOARD_NAME"] }
    lists = board.lists
    ENV["TRELLO_LIST_NAMES"].split(",").each do |list_name|
      list = lists.find { |list| list.name == list_name }
      config = ConfigRepository.new("trello-#{list_name.downcase}")
      colour_calculator = ColourCalculator.new(config)
      colour = colour_calculator.get_colour(list.cards.size)
      send_event("trello-#{list_name.downcase}", { "current" => list.cards.size, "background-color" => colour })
    end
    # Training
    training = Board.all.find { |board| board.name == "Training" }
    training_lists = training.lists
    ongoing_training_cards = training_lists.select { |list| list.name != "Done" }.map(&:cards).map(&:size).inject(&:+)
    url = "https://www.goodreads.com/review/list/#{ENV["GOODREADS_LIST_ID"]}.xml?key=#{ENV["GOODREADS_KEY"]}&shelf=tech-to-read&v=2"
    doc = Nokogiri::XML(open(url))
    books = doc.xpath("//reviews").attr('total').value.to_i
    ongoing_training_cards += books
    config = ConfigRepository.new("training")
    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(ongoing_training_cards)
    send_event("training", { "current" => ongoing_training_cards, "background-color" => colour })
    # Challenges
    challenges = Board.all.find { |board| board.name == "Challenges" }
    challenge_lists = challenges.lists
    ongoing_challenge_cards = challenge_lists.select { |list| list.name != "Done" }.map(&:cards).map(&:size).inject(&:+)
    config = ConfigRepository.new("challenges")
    colour_calculator = ColourCalculator.new(config)
    colour = colour_calculator.get_colour(ongoing_challenge_cards)
    send_event("challenges", { "current" => ongoing_challenge_cards, "background-color" => colour })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
