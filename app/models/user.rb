require 'countries'

class User < ActiveRecord::Base
  GENDERS = ["Male", "Female", "Other"]
  SKILL_LEVELS = ["Beginner", "Rookie", "Amateur", "Intermediate", "Professional"]

  validates :name, presence: true, length: { in: 2..255 }
  validates :desc, length: { maximum: 65535 }
  validates :email, presence: true, length: { in: 5..254 }
  validates :birthday, presence: true
  validates :gender, presence: true
  validates :postcode, presence: true, length: { in: 3..10 }
  validates :country, presence: true
  validates :skill_level, presence: true
  validate :birthday_must_be_in_the_past
  validate :gender_must_be_within_range
  validate :country_must_have_length_of_2
  validate :skill_level_must_be_within_range
  # Validation: Birthday date must be in the past, unless you (will) have a time machine.
  def birthday_must_be_in_the_past
    errors.add(:birthday, "must be in the past") if !birthday.blank? and birthday > Date.today
  end
  # Validation: Gender must be one of the values specified in GENDERS.
  def gender_must_be_within_range
    errors.add(:gender, "must be selected") if !gender.blank? and !gender.between?(0, GENDERS.length - 1)
  end
  # Validation: Country code string must have a length of 2.
  def country_must_have_length_of_2
    errors.add(:country, "must be selected") if !country.blank? and country.length != 2
  end
  # Validation: Skill level must be one of the values specified in SKILL_LEVELS.
  def skill_level_must_be_within_range
    errors.add(:skill_level, "must be selected") if !skill_level.blank? and !skill_level.between?(0, SKILL_LEVELS.length - 1)
  end

  has_many :conversations, :foreign_key => :sender_id

  # Login/registration.
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      # If user already exists, don't update the user's data from Google except for image.
      if find_by(email: auth.info.email)
        user.image = auth.info.image.split("?")[0]
        user.save
        return user
      else
        user.uid = auth.uid
        user.provider = auth.provider
        user.name = auth.info.name
        user.image = auth.info.image.split("?")[0]
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.email = auth.info.email
        user.birthday = auth.extra.raw_info.birthday
        user.gender = auth.extra.raw_info.gender
      end
    end
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

  # Returns age of user.
  def age
    if birthday
      now = Time.now.utc.to_date
      return now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
    else
      return nil
    end
  end

end