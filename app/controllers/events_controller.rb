class EventsController < ApplicationController
  before_action :get_user, only: [:create]
  before_action :set_club, only: [:create]
  before_filter :must_be_admin, only: [:create]

  def index
  end

  def create
    # Ensure the club is verified
    if not @club.confirmed
      redirect_to @club, notice: 'Your club needs to be verified before you can create events.'
    end

    # Grab the current stage
    @stage = params[:stage]
    if not is_valid_stage @stage
      # Stage is invalid, make it valid
      @stage = Event.stage_details
    end

    # Check for the cancel event
    if params[:cancel]
      redirect_to @club, notice: 'You cancelled making that event.'
      return
    end

    # Check for back
    if params[:back]
      if @stage == Event.stage_confirm
        redirect_to create_event_path(@club, Event.stage_details)
        return
      elsif @stage == Event.stage_doit
        redirect_to create_event_path(@club, Event.stage_tickets)
        return
      end
    end

    # Check for submitted event title
    if params[:event_title] and params[:event_title].length > 0
      session[:event_title] = params[:event_title]
    end

    # Description
    if params[:event_description] and params[:event_description].length > 0
      session[:event_description] = params[:event_description]
    end

    # Event Duration
    if params[:event_duration]
      session[:event_duration] = params[:event_duration].to_i
    end

    # Date
    if params[:event_date]
      if params[:event_date]['date(1i)']
        session[:event_year] = (params[:event_date]['date(1i)']).to_i
      end

      if params[:event_date]['date(2i)']
        session[:event_month] = (params[:event_date]['date(2i)']).to_i
      end

      if params[:event_date]['date(3i)']
        session[:event_day] = (params[:event_date]['date(3i)']).to_i
      end
    end

    # Time
    if params[:event_time]
      if params[:event_time]['time(4i)']
        session[:event_hour] = params[:event_time]['time(4i)'].to_i
      end

      if params[:event_time]['time(5i)']
        session[:event_minute] = params[:event_time]['time(5i)'].to_i
      end
    end

    # Grab them
    @event_title = session[:event_title]
    @event_description = session[:event_description]
    @event_duration = session[:event_duration]
    if session[:event_year] and session[:event_month] and session[:event_day] and session[:event_hour] and session[:event_minute]
      @event_time = Time.new(session[:event_year], session[:event_month], session[:event_day], session[:event_hour], session[:event_minute])
    else
      @event_time = Time.now
    end

    # Create the event
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

  def is_valid_stage stage
    # Check if the stage is any of the valid stages
    if  stage == Event.stage_details
      return true
    end

    if stage == Event.stage_tickets
      return true
    end

    if stage == Event.stage_confirm
      return true
    end

    if stage == Event.stage_doit
      return true
    end

    # It's not at a valid stage D:
    return false
  end
end
