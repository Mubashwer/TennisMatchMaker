class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update]
    before_filter :require_permission, only: [:edit, :update]

    def require_permission
        if current_user != User.find(params[:id])
            redirect_to root_path
        end
    end


    # GET /users/1/edit
    def edit
    end

    def show
        if current_user.nil? then redirect_to root_path end
        @matches = Match.previous_matches(@user.id)
        @myprofile = false
        if current_user.id == @user.id then @myprofile = true end

        @users = User.where.not("id = ?",current_user.id).order("created_at DESC")
        @conversations = Conversation.involving(current_user).order("created_at DESC")
    end

    def update
        respond_to do |format|
            if @user.update(user_params)
                format.html { redirect_to @user, notice: 'Address was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: 'edit' }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:postcode, :country)
    end


end
