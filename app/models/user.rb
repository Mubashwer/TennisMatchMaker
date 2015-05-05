class User < ActiveRecord::Base
  validates :name, presence: true
  validates :postcode, presence: true

  has_many :conversations, :foreign_key => :sender_id

  GENDERS = ["Male", "Female", "Other"]  # Not really used, gender is stored as a string, not an integer...
  SKILL_LEVELS = ["Beginner", "Rookie", "Amateur", "Intermediate", "Professional"]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      return user if find_by_email(auth.info.email) #dont re-read data if user alraedy registerd
      user.uid = auth.uid
      user.provider = auth.provider
      user.name = auth.info.name
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.email = auth.info.email
      user.image = auth.info.image.split("?")[0]
      user.gender = auth.extra.raw_info.gender
      user.birthday = auth.extra.raw_info.birthday
    end
  end

  def location
    if postcode and country
      return postcode.to_s + " " + country
    elsif postcode
      return postcode.to_s
    elsif country
      return country
    else
      return nil
    end
  end

  def age
    if birthday
      now = Time.now.utc.to_date
      return now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
    else
      return nil
    end
  end

end