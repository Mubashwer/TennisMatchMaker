
module MessagesHelper
  def self_or_other(message)
    message.user == current_user ? "self" : "other"
  end
 
  def message_interlocutor(message)
    message.user = User.find_by_id(message.user_id)
    #message.user == message.conversation.sender ? message.conversation.sender : message.conversation.recipient
  end
  def emojify(content)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#$1" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if content.present?
  end


end