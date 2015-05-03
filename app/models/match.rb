class Match < ActiveRecord::Base
  belongs_to :conversation
  validates_length_of :court, :maximum => 50, :allow_blank => true
  validates_length_of :desc, :maximum => 100, :allow_blank => true

  def self.created_matches(pid)
  	return Match.find_all_by_player1_id(pid)
  end

  def self.user_matches(pid)
    return Match.where("player1_id = #{pid} or player2_id = #{pid} or player3_id = #{pid} or player4_id = #{pid} ")
  end

  def self.previous_matches(pid)
    return Match.user_matches(pid).where("end < ?", Time.now.utc.to_s(:db)).order("end DESC")
  end

  def self.upcoming_matches(pid)
    return Match.user_matches(pid).where("end >= ?", Time.now.utc.to_s(:db)).order("end ASC")
  end

  def self.find_match(user)
    require 'open-uri'

    match_distances = []

    p1_postcode = user.postcode

    Match.all.each do |match|

      m = User.find_by(id:match.player1_id)
      if m.id != user.id
      
        tmp = [match.id]
        p2_postcode = (m).postcode

        url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{p1_postcode}%2CAustralia&destinations=#{p2_postcode}%2CAustralia"
        doc = JSON.parse(open(url).read)
        if (doc == {})
          tmp << doc["rows"][0]["elements"][0]["distance"]["value"]
        else
          tmp << 100000
        end
        match_distances << tmp
      end
    end

    return match_distances.sort{|id,dist| dist <=> id}

  end

end
