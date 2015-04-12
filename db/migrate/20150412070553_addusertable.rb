class Addusertable < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :image
      t.string :birthday
      t.string :email
      t.string :gender

      t.timestamps
    end
  end
end
