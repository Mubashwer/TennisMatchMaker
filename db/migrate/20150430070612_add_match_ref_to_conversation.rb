class AddMatchRefToConversation < ActiveRecord::Migration
  def change
    add_reference :conversations, :match, index: true
  end
end
