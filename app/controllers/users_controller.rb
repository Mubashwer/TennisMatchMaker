class UsersController < ApplicationController
  def show
  	    @user = User.find(params[:id])
  	    if current_user.nil? then redirect_to root_path end
        respond_to do |format|
            format.html
            format.json { render json: @user }
        end
  end
end
