require 'open-uri'
require 'cgi'

class Match < ActiveRecord::Base
  MATCH_TYPES = ["Singles", "Doubles", "Men's Singles", "Women's Singles", "Men's Doubles", "Women's Doubles", "Mixed Doubles"]
  MALE_GENDER_VALID_MATCH_TYPES = ["Singles", "Doubles", "Men's Singles", "Men's Doubles", "Mixed Doubles"]
  FEMALE_GENDER_VALID_MATCH_TYPES = ["Singles", "Doubles", "Women's Singles", "Women's Doubles", "Mixed Doubles"]
  OTHER_GENDER_VALID_MATCH_TYPES = ["Singles", "Doubles"]
  GENDER_VALID_MATCH_TYPES = {0 => MALE_GENDER_VALID_MATCH_TYPES,
                              1 => FEMALE_GENDER_VALID_MATCH_TYPES,
                              2 => OTHER_GENDER_VALID_MATCH_TYPES}

  validates :desc, length: { maximum: 96 }
  validates :start, presence: true
  validates :postcode, presence: true
  validates :country, presence: true
  validates :duration_days, presence: true, numericality: true
  validates :duration_hours, presence: true, numericality: true
  validates :court, length: { maximum: 48 }
  validate :start_must_be_in_the_future
  validate :duration_days_must_be_positive
  validate :duration_days_must_be_less_than_5
  validate :duration_hours_must_be_positive
  validate :duration_hours_must_be_less_than_23
  validate :duration_days_and_duration_hours_sum_must_be_positive
  validate :match_type_must_be_confined_to_gender
  # Validation: Start date must be in the future.
  def start_must_be_in_the_future
    errors.add(:start, "must be in the future") if !start.blank? and start < DateTime.now
  end
  # Validation: Duration days must be positive.
  def duration_days_must_be_positive
    errors.add(:duration_days, "must be selected") if !duration_days.blank? and duration_days < 0
  end
  # Validation: Duration days must be less than 5 days. Optional validation.
  def duration_days_must_be_less_than_5
    errors.add(:duration_days, "must be selected") if !duration_days.blank? and duration_days >= 5
  end
  # Validation: Duration hours must be positive.
  def duration_hours_must_be_positive
    errors.add(:duration_hours, "must be selected") if !duration_hours.blank? and duration_hours < 0
  end
  # Validation: Duration hours must be less than 23 hours.
  def duration_hours_must_be_less_than_23
    errors.add(:duration_hours, "must be selected") if !duration_hours.blank? and duration_hours >= 24
  end
  # Validation: Duration hours + duration days must be greater than 0.
  def duration_days_and_duration_hours_sum_must_be_positive
    errors.add(:duration_hours, "must be greater than 0") if !duration_days.blank? and !duration_hours.blank? and duration_days + duration_hours <= 0
  end
  # Validation: Certain genders cannot create certain match types.
  def match_type_must_be_confined_to_gender
    current_user = User.find(player1_id)
    if !current_user.blank? and !GENDER_VALID_MATCH_TYPES[current_user.gender].include?(match_type)
      errors.add(:match_type, "can't be created by you")
    end
  end

  belongs_to :conversation

  def self.created_matches(pid)
  	return Match.find_all_by_player1_id(pid)
  end

  def self.user_matches(pid)
    return Match.where("player1_id = ? or player2_id = ? or player3_id = ? or player4_id = ?", pid, pid, pid, pid)
  end

  def self.previous_matches(pid)
    return Match.user_matches(pid).where("end < ?", Time.now.utc.to_s(:db)).order("end DESC")
  end

  def self.upcoming_matches(pid)
    return Match.user_matches(pid).where("end >= ?", Time.now.utc.to_s(:db)).order("end ASC")
  end

  def self.find_match(user, match_type, after)
    # Filter matches from the following:
    #   Self created matches,
    #   Gender restricted matches,
    #   Queried matches,
    #   Already past matches (using start date).
    #   Full matches,
    matches = Match.all.select do |m|
      m.player1_id != user.id and
      GENDER_VALID_MATCH_TYPES[user.gender].include?(m.match_type) and
      (match_type == "Any" or m.match_type == match_type) and
      m.start > DateTime.now and
      (after == nil or after.class != Date or m.end.to_date >= after) and
      !m.full?
    end

    # Array holding distance between user and filtered matches - currently using
    #   match's first player's postcode as match's postcode.
    match_distances = []
    origin = user.location

    # Populate match_distances.
    matches.each do |match|
      destination = match.location
      url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{ENV['GOOGLE_API_KEY']}&origins=#{CGI.escape(origin)}&destinations=#{CGI.escape(destination)}"
      doc = JSON.parse(open(url).read)
      tmp = [match.id]
      if (doc["status"] == "OK" and doc["rows"][0]["elements"][0]["status"] == "OK")
        tmp.push(doc["rows"][0]["elements"][0]["distance"]["value"])
      else
        tmp.push(nil)
      end
      match_distances.push(tmp)
    end

    # Sort and return.
    return match_distances.sort{ |e1, e2| (e1[1] or Float::INFINITY) <=> (e2[1] or Float::INFINITY) }
  end

  # Returns either (in fallback order):
  #   Postcode concatenated with country name,
  #   Postcode concatenated with country code,
  #   Postcode or country name or country code.
  def location
    c = Country.find_country_by_alpha2(country)
    country_name = !c.nil? ? c.name : nil
    if (postcode and country)
      return postcode + ", " + (country_name or country)
    else
      return (postcode or country_name or country)
    end
  end

  # Returns match start date.
  def start_date
    return start
  end

  # Returns match end date.
  def end_date
    return (start and duration_days and duration_hours) ? (start + duration_days.days + duration_hours.hours) : nil
  end

  # Returns players in match.
  def players
    return [User.find_by(id: player1_id), User.find_by(id: player2_id),
    User.find_by(id: player3_id), User.find_by(id: player4_id)].reject { |u| u.nil? }
  end
  alias_method :users, :players

  # Returns false if match is not completely filled with players, else true.
  def full?
    if match_type.include?("Doubles") and players.length < 4
      return false
    elsif match_type.include?("Singles") and players.length < 2
      return false
    else
      return true
    end
  end
end
