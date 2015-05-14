class AddDurationToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :duration, :float
  end
end
