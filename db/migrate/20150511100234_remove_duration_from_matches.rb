class RemoveDurationFromMatches < ActiveRecord::Migration
  def change
    remove_column :matches, :duration, :integer
  end
end
