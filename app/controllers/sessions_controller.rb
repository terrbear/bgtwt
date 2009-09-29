class SessionsController < ApplicationController
  layout :check_bgtwt_layout

  def create
    open_id_authentication(params[:openid_identifier])
  end

  def destroy
    reset_session
    flash[:notice] = "You've been logged out"
    if params[:no_layout]
      redirect_to :controller => :tweets, :no_layout => true
    else
      redirect_to :controller => :tweets
    end
  end

protected
  def open_id_authentication(openid)
    authenticate_with_open_id(openid) do |result, identity_url, registration|
	    if result.successful?
	      if @current_user = User.find_by_identity_url(identity_url)
	        successful_login
        elsif @current_user = User.create(:identity_url => identity_url)
          successful_login(true)
        else
          failed_login "wtf are you doing?"
	      end
	    else
	      failed_login result.message
	    end
    end
  end
    
private
  def successful_login(needs_info = false)
    session[:user_id] = @current_user.id
    if needs_info
      redirect_to(edit_user_path(@current_user))
    else
      redirect_to(root_url)
    end
  end

  def failed_login(message)
    flash[:notice] = message
    redirect_to(new_session_url)
  end
end
