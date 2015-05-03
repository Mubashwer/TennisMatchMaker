class AddSkillLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :skill_level, :integer
  end
end
