class MatchesController < ApplicationController
  before_action :authenticate_user
  before_action :set_match, only: [:show, :edit, :update, :destroy, :join, :kick]
  

  include MatchesHelper
  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.all
    @match_distances = Match.find_match(current_user)
  end

  # GET /matches/1
  # GET /matches/1.json
  def show

    @conversation = Conversation.find_by_id(@match.conversation_id)
    @messages = @conversation.messages
    @message = Message.new

  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)
    @match.player1_id = current_user.id
    conv = Conversation.new
    conv.match_id = @match.id
    conv.save!
    @match.conversation_id = conv.id


    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: ['Match was successfully created.', "alert alert-dismissible alert-success"] }
        format.json { render action: 'show', status: :created, location: @match }
      else
        format.html { render action: 'new' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to @match, notice: ['Match was successfully updated.', "alert alert-dismissible alert-success"] }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  def join
    pids = get_player_list(@match).map{|p| p.try(:id)} # list of player ids
    status = false
    if can_join(pids) #if possible, join
      status = join_now(@match, current_user.id)
      done = ["joined", "success"]
    elsif pids.include?(current_user.id) #if already joined, then leave
      status = leave_now(@match, current_user.id, @host)
      done = ["left", "warning"]
      if !get_player_list(@match).any? #if there is no more players in match, then destroy
        destroy
        return
      end
    end

    respond_to do |format|
      if status and @match.save!
        format.html { redirect_to @match, notice: ['You have succesfully ' + done[0] + ' the match.', "alert alert-dismissible alert-" + done[1]] }
      else
        format.html { redirect_to @match, notice: ['Sorry, your request could not be processed.', "alert alert-dismissible alert-danger"] }
      end
    end
  end

  def kick
    status = false
    pid = params[:match][:pid].to_i
    # find and kick player out by setting foreign key to nil
    if (@match.player2_id == pid) then @match.player2_id = nil; status = true
    elsif (@match.player3_id == pid) then @match.player3_id = nil; status = true
    elsif (@match.player4_id == pid) then @match.player4_id = nil; status = true
    end

    respond_to do |format|
      if status and @match.save!
        format.html { redirect_to @match, notice: ['Player have been successfully kicked out.', "alert alert-dismissible alert-success" ] }
      else
        format.html { redirect_to @match, notice: ['Sorry, your request could not be processed.', "alert alert-dismissible alert-danger"] }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
   @match.destroy

    respond_to do |format|
      format.html { redirect_to matches_url, notice: ['You have succesfully left the match.', "alert alert-dismissible alert-warning"]}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
      @host = false
      if current_user and current_user.id == @match.player1_id
        @host = true
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:start, :end, :court, :desc, :match_type, :pid)
    end
end
