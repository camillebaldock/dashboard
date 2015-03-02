require 'trello'

include Trello

Trello.configure do |config|
  config.developer_public_key = ENV["TRELLO_DEVELOPER_KEY"]
  config.member_token = ENV["TRELLO_MEMBER_TOKEN"]
end

SCHEDULER.every "30m" do
  logger = Logger.new("trello")
  logger.start
  begin
    board = Board.all.find { |board| board.name == ENV["TRELLO_BOARD_NAME"] }
    lists = board.lists
    ENV["TRELLO_LIST_NAMES"].split(",").each do |list_name|
      list = lists.find { |list| list.name == list_name }
      send_event("trello-#{list_name.downcase}", { current: list.cards.size })
    end
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
