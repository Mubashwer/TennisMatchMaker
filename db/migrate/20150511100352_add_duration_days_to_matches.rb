class AddDurationDaysToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :duration_days, :integer
  end
end
