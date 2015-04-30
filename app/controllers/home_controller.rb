class HomeController < ApplicationController
  def index
      if current_user
        if (current_user.postcode.nil? or current_user.country.nil?)
   			redirect_to edit_user_path(current_user)
  		end
      end
  end
end
