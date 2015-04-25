class AddPostcodeCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :postcode, :int
    add_column :users, :country, :string
  end
end
