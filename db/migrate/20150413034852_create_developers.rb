class CreateDevelopers < ActiveRecord::Migration
  def change
    create_table :developers do |t|
      t.string :display_name
      t.string :email
      t.string :display_picture_url
      t.text :biography

      t.timestamps
    end
  end
end
