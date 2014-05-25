class NetworkController < ApplicationController
  before_action :set_club, only: [:create]
  before_action :set_network, only: [:show]
  before_action :set_admin, only: [:create]
  before_filter :authenticate_user!
  before_filter :must_be_admin, only: [:create]

  def create
    # Check if they've submitted the form
    if params[:create]
      @network_name = params[:network_name]
      if @network_name.length == 0
        @error_message = 'That name is too short.'
        return
      end

      # Create the network
      n = Network.create({
        :name => @network_name
      })

      if n.save()
        # Add this club to that network
        nc = ClubNetwork.create({
          club_id: @club.id,
          network_id: n.id,
          verified: true
        })

        # Attempt to save this club into the network
        if nc.save()
          redirect_to network_page_path n
        else
          @error_message = 'Failed to join network.'
          return
        end
      else
        @error_message = 'Failed to create network.'
        return
      end
    end
  end

  def show
    # Check if they tried to invite someone
    if params[:invite]
      @club = Club.find(params[:club_id])


      # Check if they are already part of the network
      taken = false
      @clubs.each do |club|
        if club.id == @club.id
          taken = true
        end
      end
      @u_clubs.each do |club|
        if club.id == @club.id
          taken = true
        end
      end

      if taken
        redirect_to network_page_path(@network), notice: 'This club has already been invited.'
        return
      end

      # Send out the invite
      nc = ClubNetwork.create({
        club_id: @club.id,
        network_id: @network.id,
        verified: false
      })

      redirect_to network_page_path(@network), notice: 'The club was invited.'
    end
  end

  private
    def set_club
      @club = Club.find(params[:clubID])
    end

    def set_network
      @network = Network.find(params[:networkID])
      @clubs = @network.clubs
      @u_clubs = @network.u_clubs

      # Set admin flag
      @is_admin = @network.memberships.exists?(:user_id => current_user.id, :rank => User.rank_admin)
    end

    def set_admin
      if user_signed_in?
        @is_club_member = current_user.memberships.exists?(:club_id => @club.id)
        @is_club_admin = current_user.memberships.exists?(:club_id => @club.id, :rank => User.rank_admin)
      end
    end

    def must_be_admin
      if not @is_club_admin
        redirect_to @club, notice: 'You need to be an admin to do this.'
        return false
      end
    end
end
