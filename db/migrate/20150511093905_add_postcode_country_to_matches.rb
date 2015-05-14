class AddPostcodeCountryToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :postcode, :string
    add_column :matches, :country, :string
  end
end
