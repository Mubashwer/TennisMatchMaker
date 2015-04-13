class AddPersonToDeveloper < ActiveRecord::Migration
  def self.up
    Developer.new(:display_name => "Rupert")
  end
end
