class ChangePostcodeTypeFromUsers < ActiveRecord::Migration
  def change
  	change_column :users, :postcode, :string
  end
end
