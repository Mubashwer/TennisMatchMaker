class HomeController < ApplicationController
  def index
      if current_user
        if (current_user.postcode.nil? or current_user.country.nil?)
   			redirect_to edit_user_path(current_user)
  		end
         @users = User.where.not("id = ?",current_user.id).order("created_at DESC")
         @conversations = Conversation.involving(current_user).order("created_at DESC")
      end
  end
end
