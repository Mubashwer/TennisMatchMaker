class AddDurationHoursToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :duration_hours, :integer
  end
end
