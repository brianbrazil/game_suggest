class Boardgame
  def initialize(doc)
    @doc = doc
  end

  def name
    doc.elements.select { |el| el.name == 'name' && el.attributes['primary'].present? }.first.text
  end

  def description
    doc.elements.select { |el| el.name == 'description' }.first.text
  end

  def designers
    doc.elements.select { |el| el.name == 'boardgamedesigner' }.map(&:text)
  end

  def min_players
    doc.minplayers.text.to_i
  end

  def max_players
    doc.maxplayers.text.to_i
  end

  def min_playtime
    doc.minplaytime.text.to_i
  end

  def max_playtime
    doc.maxplaytime.text.to_i
  end

  def average_rating
    doc.statistics.ratings.average.text.to_f
  end

  def suggested_num_players
    (min_players..max_players).each_with_object({}) do |num_players, memo|
      memo[num_players] = {
        best: votes_for_best_with_n_players(num_players),
        recommended: votes_for_recommended_with_n_players(num_players),
        not_recommended: votes_for_not_recommended_with_n_players(num_players),
      }
    end
  end

  def ordered_suggested_num_players
    weighted_suggested_num_players.sort_by { |_k,v| v }.reverse.to_h.keys
  end

  def weighted_suggested_num_players
    (min_players..max_players).each_with_object({}) do |num, memo|
      memo[num] = weighted_votes_with_n_players(num) if weighted_votes_with_n_players(num) > 0
    end
  end

  def best_num_players
    suggested_num_players.select do |_num, votes|
      votes[:best] > votes[:recommended] + votes[:not_recommended]
    end.keys
  end

  def recommended_num_players
    suggested_num_players.select do |_num, votes|
      votes[:recommended] + votes[:best] > votes[:not_recommended]
    end.keys
  end

  def not_recommended_num_players
    suggested_num_players.select do |_num, votes|
      votes[:not_recommended] > votes[:best] + votes[:recommended]
    end.keys
  end

  private

  attr_reader :doc

  def weighted_votes_with_n_players(n)
    ( (votes_for_best_with_n_players(n) * 2) + votes_for_recommended_with_n_players(n) - votes_for_not_recommended_with_n_players(n) ) / (votes_total_with_n_players(n) * 2).to_f
  end

  def votes_total_with_n_players(n)
    votes_for_best_with_n_players(n) + votes_for_recommended_with_n_players(n) + votes_for_not_recommended_with_n_players(n)
  end

  def votes_for_best_with_n_players(n)
    doc.poll("[@name='suggested_numplayers']").results("[@numplayers='#{n}']").result("[@value='Best']")["numvotes"].to_i
  rescue
    0
  end

  def votes_for_recommended_with_n_players(n)
    doc.poll("[@name='suggested_numplayers']").results("[@numplayers='#{n}']").result("[@value='Recommended']")["numvotes"].to_i
  rescue
    0
  end

  def votes_for_not_recommended_with_n_players(n)
    doc.poll("[@name='suggested_numplayers']").results("[@numplayers='#{n}']").result("[@value='Not Recommended']")["numvotes"].to_i
  rescue
    0
  end
end
