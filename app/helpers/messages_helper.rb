
module MessagesHelper
  def self_or_other(message)
    message.user == current_user ? "self" : "other"
  end
 
  def message_interlocutor(message)
    message.user = User.find_by_id(message.user_id)
    #message.user == message.conversation.sender ? message.conversation.sender : message.conversation.recipient
  end

end