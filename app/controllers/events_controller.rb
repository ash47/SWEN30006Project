class EventsController < ApplicationController
  before_action :get_user, only: [:create]
  before_action :set_club, only: [:create]
  before_filter :must_be_admin, only: [:create]
  before_action :get_notice, only: [:create]
  before_action :get_event, only: [:show]

  def index
    @events = Event.all
  end

  def show
    @club = @event.club
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

    # Check if they are making a brand new event
    if @stage == Event.stage_new
      # Clear all event data
      session.delete(:event_title)
      session.delete(:event_description)
      session.delete(:event_duration)
      session.delete(:event_year)
      session.delete(:event_month)
      session.delete(:event_day)
      session.delete(:event_hour)
      session.delete(:event_minute)
      session.delete(:event_tickets)

      # Redirect to details page
      redirect_to create_event_path(@club, Event.stage_details)
      return
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

    # Ensure there is a ticket storage
    session[:event_tickets] ||= []

    # Adding Tickets
    if params[:addticket]
      # User is trying to add a new ticket

      # Make sure they are on the correct stage
      if @stage == Event.stage_confirm
        # Grab ticket info
        tname = params[:event_ticket_name]
        mprice = params[:event_ticket_mprice].to_i
        nprice = params[:event_ticket_nprice].to_i
        sprice = params[:event_ticket_sprice].to_i
        total = params[:event_ticket_total].to_i

        # Validate data




        # Add the ticket to their session
        session[:event_tickets].push({
          tname: tname,
          mprice: mprice,
          nprice: nprice,
          sprice: sprice,
          total: total
        })

        # Redirect back to ticket page
        redirect_to create_event_path(@club, Event.stage_tickets)
        return
      end
    end

    # Updating Tickets
    if params[:updateticket]
      index = params[:index].to_i

      if session[:event_tickets][index]
        # Grab ticket info
        tname = params['event_ticket_name'+index.to_s]
        mprice = params['event_ticket_mprice'+index.to_s].to_i
        nprice = params['event_ticket_nprice'+index.to_s].to_i
        sprice = params['event_ticket_sprice'+index.to_s].to_i
        total = params['event_ticket_total'+index.to_s].to_i

        # Validate data


        # Update the ticket info
        session[:event_tickets][index] = {
          tname: tname,
          mprice: mprice,
          nprice: nprice,
          sprice: sprice,
          total: total
        }

        # Redirect back to tickets
        redirect_to create_event_path(@club, Event.stage_tickets, notice: 'Ticket was updated.')
        return
      else
        # Ticket index is unknown, can't update :(
        redirect_to create_event_path(@club, Event.stage_tickets, notice: 'Failed to update unknown ticket.')
        return
      end
    end

    # Remove tickets
    if params[:removeticket]
      index = params[:index].to_i

      if session[:event_tickets][index]
        session[:event_tickets].delete_at(index)
        redirect_to create_event_path(@club, Event.stage_tickets, notice: 'Ticket was removed.')
        return
      else
        redirect_to create_event_path(@club, Event.stage_tickets, notice: 'Failed to find that ticket.')
        return
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
    @event_tickets = session[:event_tickets]

    # Create the event
    if @stage == Event.stage_doit
      # Validate data


      # Create the new event
      e = Event.create({
        :club_id => @club.id,
        :start_time => @event_time,
        :duration => @event_duration,
        :description => @event_description,
        :name => @event_title
      })

      # Attempt to save the new event
      if e.save
        # Add tickets
        success = true

        # Loop over all tickets
        @event_tickets.each do |ticket|
          # Create the ticket
          t = Ticket.create({
            :event_id => e.id,
            :tname => ticket[:tname],
            :mprice => ticket[:mprice],
            :nprice => ticket[:nprice],
            :sprice => ticket[:sprice],
            :total => ticket[:total],
            :remaining => ticket[:total]
          })

          if not t.save
            success = false
          end
        end

        if success == false
          redirect_to create_event_path(@club, Event.stage_confirm, notice: 'Failed to save new event tickets.')
          return
        end

        # Success, redirect back to club
        redirect_to @club, notice: 'New event was created!'
      else
        redirect_to create_event_path(@club, Event.stage_confirm, notice: 'Failed to save new event.')
        return
      end
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

  def get_notice
    @notice = params[:notice]
  end

  def get_event
    @event = Event.find(params[:id])
    @tickets = @event.tickets
  end

  def must_be_admin
    if not @is_club_admin
      redirect_to @club, notice: 'You need to be an admin to do this.'
      return false
    end
  end

  def is_valid_stage stage
    # Check if the stage is any of the valid stages
    if  stage == Event.stage_new
      return true
    end

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
