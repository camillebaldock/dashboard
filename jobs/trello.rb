require 'trello'

include Trello

Trello.configure do |config|
  config.developer_public_key = ENV["TRELLO_DEVELOPER_KEY"]
  config.member_token = ENV["TRELLO_MEMBER_TOKEN"]
end

SCHEDULER.every "30m", first_in: 0 do
  logger = Logger.new("trello")
  logger.start
  begin
    board = Board.all.find { |board| board.name == ENV["TRELLO_BOARD_NAME"] }
    lists = board.lists
    ENV["TRELLO_LIST_NAMES"].split(",").each do |list_name|
      list = lists.find { |list| list.name == list_name }
      send_event("trello-#{list_name.downcase}", { current: list.cards.size })
    end
    # Training
    training = Board.all.find { |board| board.name == "Training" }
    training_lists = training.lists
    ongoing_training_cards = training_lists.select { |list| list.name != "Done" }.map(&:cards).map(&:size).inject(&:+)
    send_event("training", { current: ongoing_training_cards })
    # Challenges
    challenges = Board.all.find { |board| board.name == "Challenges" }
    challenge_lists = challenges.lists
    ongoing_challenge_cards = challenge_lists.select { |list| list.name != "Done" }.map(&:cards).map(&:size).inject(&:+)
    send_event("challenges", { current: ongoing_challenge_cards })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
