class AddDataToDeveloper < ActiveRecord::Migration
  def change
    Developers.new(:display_name => "Rupert Allan")
  end
end
