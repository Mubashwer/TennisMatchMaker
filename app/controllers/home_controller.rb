class HomeController < ApplicationController
  def index
      if current_user
         @users = User.where.not("id = ?",current_user.id).order("created_at DESC")
         @conversations = Conversation.involving(current_user).order("created_at DESC")
      end
  end
end
