class EventsController < ApplicationController
  before_action :set_club, only: [:create]
  before_action :get_event, only: [:show, :tickets, :mark_ticket]
  before_action :get_club, only: [:mark_ticket, :show]
  before_action :set_admin, only: [:create, :show, :mark_ticket]
  before_filter :authenticate_user!
  before_filter :must_be_admin, only: [:create, :mark_ticket]
  before_action :get_notice, only: [:create, :show]
  before_action :get_reservations, only: [:show, :tickets]

  def index
    if params[:search] and params[:key_word].length > 0
      @key_word = params[:key_word]
      @events = Event.where('name LIKE ?', '%'+params[:key_word]+'%').all
    else
      @events = Event.all
    end
  end

  def show
    if @is_club_admin
      @all_reseverations = @event.ticket_reservations
    end

    if user_signed_in?
      if params[:comment]
        text = params[:text]

        # Create the comment
        c = Comment.create({
          user_id: current_user.id,
          event_id: @event.id,
          message: text
        })

        # Attempt to save the comment
        if c.save()
          redirect_to event_path(@event, notice: 'Added your comment.')
        else
          redirect_to event_path(@event, notice: 'Comment failed to save.')
        end
      end
    end

    # Load comments
    @comments = Comment.where(:event_id => @event.id)
  end

  def mark_ticket
    ticketID = params[:ticketID]

    # Find the ticket
    ticket = TicketReservation.find(ticketID)

    if ticket.pickedup
      redirect_to event_path(@event, notice: 'This ticket has already been marked as picked up.')
    else
      ticket.pickedup = true
      ticket.save()
      redirect_to event_path(@event, notice: 'Ticket was marked as picked up.')
    end
  end

  def tickets
    # Ensure the user is signed in
    if not user_signed_in?
      redirect_to event_path(@event)
      return
    end

    # Check if this user already made reservations
    if @reservations.count > 0
      redirect_to event_path(@event, notice: 'You have already reserved tickets.')
    end

    @tickets = @event.tickets

    # Check for submitted data
    if params[:cancel]
      # User trying to cancel their reservations
      redirect_to event_path(@event)
    end

    # Stores what the user entered for each amount
    @ticket_amounts = {}

    # Stores the reservations to make
    @resev = {}

    # User tried to reserve tickets
    if params[:reserve]
      # The total number of tickets this user is asking for
      total = 0

      # Validate selection
      @tickets.each.with_index(0) do |ticket, index|
        # Grab ticket amounts
        m_amount = params['m_amount'+index.to_s].to_i.abs
        n_amount = params['n_amount'+index.to_s].to_i.abs
        s_amount = params['s_amount'+index.to_s].to_i.abs

        # Copy ticket numbers for client
        @ticket_amounts['m'+index.to_s] = m_amount
        @ticket_amounts['n'+index.to_s] = n_amount
        @ticket_amounts['s'+index.to_s] = s_amount

        # Workout the total number of tickets needed
        amount = m_amount+n_amount+s_amount
        total += amount

        # Check if the tickets are closed
        now = Time.now
        open = now >= ticket[:opendate] and now <= ticket[:closedate]
        if amount > 0 and not open
          @error_message = 'You can\'t reserve tickets for this class.'
        end

        # See if there are even that many left
        if total > ticket.remaining
          @error_message = 'You tried to reserve more tickets then there are available.'
        end

        # See if this user is asking for more then they are allowed
        if total > Ticket.max_tickets
          @error_message = 'You are only allowed to reserve '+Ticket.max_tickets.to_s+' at a time.'
        end

        # Store reservations
        if amount > 0
          @resev[index] = {
            :m_amount => m_amount,
            :n_amount => n_amount,
            :s_amount => s_amount,
            :total => m_amount+n_amount+s_amount,
            :ticket => ticket
          }
        end
      end

      # Check if they tried to reserve no tickets
      if total == 0
        @error_message = 'Please enter how many tickets you want to reserve.'
      end

      # Check if there was an error
      if @error_message
        return
      end

      # It all checks out, do the reservations
      @resev.each do |key, r|

        # Create the reservation
        res = TicketReservation.create({
          :user_id => current_user.id,
          :ticket_id => r[:ticket].id,
          :event_id => @event.id,
          :m_amount => r[:m_amount],
          :n_amount => r[:n_amount],
          :s_amount => r[:s_amount]
        })

        # Lower the amount of tickets left
        r[:ticket].remaining -= r[:total]
        r[:ticket].save()

        # Attempt to save the reservation
        if not res.save()
          @error_message = 'Failed to save ticket reservations.'
          return
        end
      end

      # Redirect back to event page
      redirect_to event_path(@event, notice: 'Your tickets have been reserved.')
    end
  end

  def create
    # Ensure the club is verified
    if not @club.confirmed
      redirect_to @club, notice: 'Your club needs to be verified before you can create events.'
      return
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
      session.delete(:event_location)
      session.delete(:event_year)
      session.delete(:event_month)
      session.delete(:event_day)
      session.delete(:event_hour)
      session.delete(:event_minute)
      session.delete(:event_tickets)
      session.delete(:event_imagea)
      session.delete(:event_imageb)
      session.delete(:event_imagec)

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

    # Event Location
    if params[:event_location] and params[:event_location].length > 0
      session[:event_location] = params[:event_location]
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

    # Images
    if params[:imagea]
      session[:event_imagea] = store_file params[:imagea]
    end
    if params[:imageb]
      session[:event_imageb] = store_file params[:imageb]
    end
    if params[:imagec]
      session[:event_imagec] = store_file params[:imagec]
    end

    @imagea = session[:event_imagea]
    @imageb = session[:event_imageb]
    @imagec = session[:event_imagec]

    # Ensure there is a ticket storage
    session[:event_tickets] ||= []

    # Adding Tickets
    if params[:addticket]
      # User is trying to add a new ticket

      # Make sure they are on the correct stage
      if @stage == Event.stage_confirm
        # Grab ticket info
        tname = params[:event_ticket_name]
        mprice = params[:event_ticket_mprice].to_f.round(2)
        nprice = params[:event_ticket_nprice].to_f.round(2)
        sprice = params[:event_ticket_sprice].to_f.round(2)
        total = params[:event_ticket_total].to_i
        pickup = params[:event_ticket_pickup]

        # Opening time
        open = params[:event_ticket_open]
        openyear = open['date(1i)']
        openmonth = open['date(2i)']
        openday = open['date(3i)']
        opendate = Time.new(openyear, openmonth, openday)

        # Closing time
        close = params[:event_ticket_close]
        closeyear = open['date(1i)']
        closemonth = open['date(2i)']
        closeday = open['date(3i)']
        closedate = Time.new(closeyear, closemonth, closeday)


        # Validate data




        # Add the ticket to their session
        session[:event_tickets].push({
          tname: tname,
          mprice: mprice,
          nprice: nprice,
          sprice: sprice,
          total: total,
          pickup: pickup,
          opendate: opendate,
          closedate: closedate
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
        mprice = params['event_ticket_mprice'+index.to_s].to_f.round(2)
        nprice = params['event_ticket_nprice'+index.to_s].to_f.round(2)
        sprice = params['event_ticket_sprice'+index.to_s].to_f.round(2)
        total = params['event_ticket_total'+index.to_s].to_i
        pickup = params['event_ticket_pickup'+index.to_s]

        # Opening time
        open = params['event_ticket_open'+index.to_s]
        openyear = open['date(1i)']
        openmonth = open['date(2i)']
        openday = open['date(3i)']
        opendate = Time.new(openyear, openmonth, openday)

        # Closing time
        close = params['event_ticket_close'+index.to_s]
        closeyear = close['date(1i)']
        closemonth = close['date(2i)']
        closeday = close['date(3i)']
        closedate = Time.new(closeyear, closemonth, closeday)

        # Validate data


        # Update the ticket info
        session[:event_tickets][index] = {
          tname: tname,
          mprice: mprice,
          nprice: nprice,
          sprice: sprice,
          total: total,
          pickup: pickup,
          opendate: opendate,
          closedate: closedate
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
    @event_location = session[:event_location]
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
        :name => @event_title,
        :location => @event_location,
        :imagea => @imagea,
        :imageb => @imageb,
        :imagec => @imagec
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
            :remaining => ticket[:total],
            :pickup => ticket[:pickup],
            :opendate => ticket[:opendate],
            :closedate => ticket[:closedate]
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
  end

  def get_club
    @club = @event.club
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def club_params
    params.require(:club).permit(:name, :description, :website, :uni_registration_id, :is_confirmed)
  end

  def get_notice
    @notice = params[:notice]
  end

  def get_event
    @event = Event.find(params[:id])
    @tickets = @event.tickets
  end

  def get_reservations
    if user_signed_in?
      @reservations = current_user.ticket_reservations.where(:event_id => @event.id)
    end
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

  def file_storage_location filename
    File.join(Rails.root, 'public', 'attachments', filename)
  end

  def store_file uploaded_file
    r = {}

    r[:original_filename] = uploaded_file.original_filename
    r[:size]              = uploaded_file.size
    r[:content_type]      = uploaded_file.content_type
    r[:filename]          = Digest::SHA1.hexdigest(Time.now.to_s) + r[:original_filename]
    r[:loc]               = '/attachments/'+r[:filename]
    File.open(file_storage_location(r[:filename]), "wb") {|f| f.write uploaded_file.read }

    return r[:loc]
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
