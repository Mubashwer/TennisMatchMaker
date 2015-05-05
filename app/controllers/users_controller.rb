class UsersController < ApplicationController
    before_action :authenticate_user, only:[:show, :edit, :update]
    before_action :set_user, only: [:show, :edit, :update]
    before_filter :require_permission, only: [:edit, :update]

    def require_permission
        if current_user != User.find(params[:id])
            redirect_to match_path
        end
    end

    # GET /users/new
    def new
        @user = User.from_omniauth(env["omniauth.auth"]) #get user data from google
        if User.find_by_email(@user.email) #if user alredady exists then go to home page
            session[:user_id] = @user.id
            redirect_to root_path
        end
        # if not go to registration form for sign up

    end

    def create
        @user = User.new(user_params)
        respond_to do |format|
          if @user.save
            session[:user_id] = @user.id
            format.html { redirect_to root_path }
          else
            format.html { render action: 'new' }
          end
        end
    end

    # GET /users/1/edit
    def edit
    end

    # GET /users/1
    def show
        @matches = Match.previous_matches(@user.id)
        @myprofile = false # determins whose profile it is
        if current_user.id == @user.id then @myprofile = true end

        # gets conversations of current_user (not used when you are visiting someone else's profile)
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
        @user = User.find_by_id(params[:id])
        if @user.nil? and current_user then @user = current_user end
    end

    def user_params
        params.require(:user).permit(:provider, :uid, :name, :first_name, :last_name, :gender, :image, :desc, :email, :birthday, :postcode, :country, :skill_level)
    end


end
