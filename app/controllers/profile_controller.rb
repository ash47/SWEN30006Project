class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def index
    @messages = current_user.messages
    @memberships = current_user.memberships.all
    @awaiting_verification = current_user.clubs.find(:all, :conditions => {:confirmed => false})
    @network_needs_verify = current_user.unconfirmed_networks

    # Mark all messages as read
    @messages.each do |message|
      if message.read == false
        message.read = true
        message.save
      end
    end

    # Grab ticket reservations
    @reservations = current_user.ticket_reservations
  end

  def delete_message
    # Grab the message
    message = Message.find(params[:id])
    rescue ActiveRecord::RecordNotFound

    # Verify the message exists, and the user owns it
    if message and message.user.id == current_user.id
      # Delete the message
      message.delete

      redirect_to profile_path, notice: 'Message was deleted'
      return
    else
      redirect_to profile_path, notice: 'Message was not found'
      return
    end

    redirect_to profile_path, notice: 'Message was not found'
  end
end