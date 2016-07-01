require 'queryable'

class Collection

  def initialize(doc)
    @doc = doc
  end

  def self.find(username)
    begin
       doc = Nokogiri::Slop HTTParty.get("http://www.boardgamegeek.com/xmlapi/collection/#{username}").body
    end while doc.respond_to?(:message) && doc.message.include?('Your request for this collection has been accepted and will be processed.')
    # TODO: error if doc.message.include? 'Invalid username specified'
    new(doc)
  end

  def boardgames
    @boardgames ||= begin
      games_doc = Nokogiri::Slop HTTParty.get("http://www.boardgamegeek.com/xmlapi/boardgame/#{boardgame_ids.join(',')}?stats=1").body
      games_doc.boardgames.boardgame.map { |boardgame_doc| Boardgame.new(boardgame_doc) }
    end.extend(Queryable)
  end

  def boardgame_ids
    @boardgame_ids ||= doc.items.item.map { |item| item['objectid'].to_i }
  end

  private

  attr_reader :doc
end
