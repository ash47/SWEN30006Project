class ProfileController < ApplicationController
  def index
    if not user_signed_in?
      redirect_to root_path
      return
    end
    @messages = current_user.messages
    @memberships = current_user.memberships.all
    @awaiting_verification = current_user.clubs.find(:all, :conditions => {:confirmed => false})
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
  end
end