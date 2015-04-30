class Match < ActiveRecord::Base
  belongs_to :conversation

  def self.created_matches(pid)
  	return Match.find_all_by_player1_id(pid)
  end

  def self.previous_matches(pid)
  	return Match.find_all_by_player1_id(pid) + Match.find_all_by_player2_id(pid) +\
  	       Match.find_all_by_player3_id(pid)+ Match.find_all_by_player4_id(pid)
  end

  def self.find_match(user)
    require 'open-uri'

    match_distances = []

    p1_postcode = user.postcode

    Match.all.collect do |match|
      
      tmp = [match.id]
      p2_postcode = (User.find_by(id:match.player1_id)).postcode

      url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{p1_postcode}%2CAustralia&destinations=#{p2_postcode}%2CAustralia"
      doc = JSON.parse(open(url).read)

      tmp << doc["rows"][0]["elements"][0]["distance"]["value"]
      match_distances << tmp
    end

    return match_distances.sort{|id,dist| dist <=> id}

  end

end
