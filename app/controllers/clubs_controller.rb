class ClubsController < ApplicationController
  before_action :get_user, only: [:create, :join, :index, :show, :leave, :edit, :destroy, :update]
  before_action :set_club, only: [:show, :edit, :update, :destroy, :join, :leave]
  before_filter :must_be_admin, only: [:edit, :update, :destroy]

  # GET /clubs
  # GET /clubs.json
  def index
    # Grab all confirmed clubs
    @clubs = Club.find(:all, :conditions => {:confirmed => true})

    if user_signed_in?
      @memberships = @user.memberships.all
      @awaiting_verification = @user.clubs.find(:all, :conditions => {:confirmed => false})
    end
  end

  # GET /clubs/1
  # GET /clubs/1.json
  def show
    @admins = @club.admins
    @events = @club.events
  end

  # GET /clubs/new
  def new
    @club = Club.new
  end

  # GET /clubs/1/edit
  def edit
  end

  # POST /clubs
  # POST /clubs.json
  def create
    # Create the new club
    @club = Club.new(params.require(:club).permit(:uni_registration_id))

    # Assign this user as an admin of the club
    @user.memberships.create(:club => @club, :rank => User.rank_admin)


    respond_to do |format|
      if @club.save
        format.html { redirect_to @club, notice: 'Club is now awaiting verification.' }
        format.json { render action: 'show', status: :created, location: @club }
      else
        format.html { render action: 'new' }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clubs/1
  # PATCH/PUT /clubs/1.json
  def update
    respond_to do |format|
      if @club.update(club_params)
        format.html { redirect_to @club, notice: 'Club was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clubs/1
  # DELETE /clubs/1.json
  def destroy
    @club.destroy
    respond_to do |format|
      format.html { redirect_to clubs_url }
      format.json { head :no_content }
    end
  end

  # A user is trying to join a club
  def join
    if user_signed_in?
      # Attempt to grab their membership
      membership = @club.memberships.find_by(user_id: current_user.id)
      if membership
        # User is already a member
        redirect_to @club, notice: 'You are already a member.'
      else
        # Add their membership
        @club.memberships.create(:user => @user, :rank => User.rank_member)

        redirect_to @club, notice: 'You have joined this club.'
      end
    else
      redirect_to @club, notice: 'You must sign in before you can join this club.'
    end
  end

  # A user is trying to leave a club
  def leave
    # Attempt to grab their membership
    membership = @club.memberships.find_by(user_id: current_user.id)
    if membership
      # Remove their membership
      membership.delete

      # User is already a member
      redirect_to @club, notice: 'You have left this club.'
    else
      # User isn't a member to begin with
      redirect_to @club, notice: 'You were never a member to begin with.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_club
      @club = Club.find(params[:id])

      if user_signed_in?
        @is_club_member = @user.memberships.exists?(:club_id => @club.id)
        @is_club_admin = @user.memberships.exists?(:club_id => @club.id, :rank => User.rank_admin)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def club_params
      params.require(:club).permit(:name, :description, :website, :uni_registration_id, :is_confirmed)
    end

    def get_user
      # Attempt to get user info
      if user_signed_in?
        @user = User.find(current_user.id)
      end
    end

    def must_be_admin
      if not @is_club_admin
        redirect_to @club, notice: 'You need to be an admin to do this.'
        return false
      end
    end
end
