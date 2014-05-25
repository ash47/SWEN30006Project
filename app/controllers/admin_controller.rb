class AdminController < ApplicationController
  before_action :get_user, only: [:become_admin, :remove_admin]
  before_action :find_unverified_clubs, only: [:index]
  before_filter :authenticate_user!
  before_action :get_club, only: [:verify]

  def index

  end

  # Verify a club
  def verify
    # Check if they submitted the form
    if request.patch?
      # Grab data
      data = params.require(:club).permit(:name, :website)

      # Grab the owner of the club
      @owner = @club.admins.first

      # Check if user tried to verify
      if params[:verify]
        # Ensure a name was entered
        if not data.key?(:name) or data[:name] == ""
          @error_message = "Please enter a club name"
          return
        end

        # Copy data in
        @club.name = data[:name]
        @club.website = data[:website]
        @club.confirmed = true

        # Save and redirect
        @club.save()

        # Add a message for the owner
        @owner.messages.create({
          :message => 'Your club '+@club.name+' has been verified.'
        })

        redirect_to admin_path, notice: 'Club was verified!'
        return
      end

      # Check if the user tried to reject
      if params[:reject]
        # Grab the reason
        reason = params[:reason]

        # Add a message for the owner
        @owner.messages.create({
          :message => 'Your club with ID '+params[:id]+' has been rejected with the reason: '+reason
        })

        # Clear all memberships
        @club.memberships.each do |membership|
          membership.delete
        end

        # Delete the club
        @club.delete

        redirect_to admin_path, notice: 'Club was rejected!'
        return
      end

      @error_message = "Please either verify or reject."
    end
  end

  def become_admin
    # Check if they are already an admin
    if @user.admin
      # Already an admin
      redirect_to root_path, notice: 'You are already an admin.'
    else
      # Become an admin
      @user.admin = true
      @user.save
      redirect_to root_path, notice: 'You are now an admin.'
    end
  end

  def remove_admin
    # Check if they are an admin
    if @user.admin
      # Remove admin state
      @user.admin = false
      @user.save
      redirect_to root_path, notice: 'You are no longer an admin.'
    else
      # Not an admin
      redirect_to root_path, notice: 'You were never an admin to begin with.'
    end
  end

  private
    def get_user
      # Attempt to get user info
      @user_id = current_user.try :id
      if @user_id
        @user = User.find(@user_id)
      end
    end

    def find_unverified_clubs
      @uclubs = Club.find(:all, :conditions => {:confirmed => false})
    end

    def get_club
      @club = Club.find(params[:id])
    end
end