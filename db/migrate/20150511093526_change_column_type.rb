class ChangeColumnType < ActiveRecord::Migration
  def change
    change_column :matches, :duration, :integer
  end
end
