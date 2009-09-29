class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :twitters, :callback, :export]
  
  layout :check_bgtwt_layout

  def export
    render(:xml => current_user.tweets.to_xml(:except => [:sticky, :score, :user_id, :updated_at]))
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    
    @max = 5 #this is for ghetto iphone paging
    @more = @user.tweets.public.parents.size > @max #this is for ghetto iphone paging
    
    @tweets = @user.tweets.public.parents.paginate(:page => params[:page], :per_page => @max)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
      format.iphone # show.iphone.erb
    end
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "No user with that ID"
    respond_to do |format|
      format.html { redirect_to(:controller => :tweets, :action => :index) }
      format.xml { render :nothing => true, :status => 404 }
    end
  end

  def user_feed_more
    @user = User.find(params[:id])
    
    @max = params[:max].to_i if (params[:max].to_i rescue false)
    @max = (@max.nil? || @max > 25 || @max <= 0) ? 25 : @max
    
    @current = params[:current].to_i if (params[:current].to_i rescue false)
    @current = (@current.nil? || @current < 0) ? 0 : @current
    @less = @current > 0
    @tweets =  @user.tweets.public.parents.find(:all, :order => 'created_at desc', :limit => @max+1, :offset => @current)
    @more=false
    @odd = params[:odd]
    if !@tweets.nil? && @tweets.size > @max
      @tweets.delete_at(@tweets.size-1)
      @more=true
    end
    respond_to do |format|
      format.iphone
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    params[:user].delete(:id)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Profile updated successfully!'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def self.consumer
    #both of these keys are stored in @terrbear's account
    OAuth::Consumer.new("CNGlbvEyCZdjEGPk8ackw",
                        "I3rmnFTMvFwY9YOQNcQ13X7lJcEtygjEQceShy7E4",
                        { :site=>"http://twitter.com" })
  end

  #confusing as fuck name? sure, but it was good enough
  #for oprah.
  def twitters
    @request_token = UsersController.consumer.get_request_token
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
    # Send to twitter.com to authorize
    return redirect_to(@request_token.authorize_url)
  end

  def callback
    @request_token = OAuth::RequestToken.new(UsersController.consumer,
                                            session[:request_token],
                                            session[:request_token_secret])

    # Exchange the request token for an access token.
    @access_token = @request_token.get_access_token

    response = UsersController.consumer.request(:get, '/account/verify_credentials.json',
                                              @access_token, { :scheme => :query_string })
    
    if !(Net::HTTPSuccess === response)
      logger.error{"Failed to get user info via OAuth"}
      flash[:notice] = "Twitter authentication failed."
      return(redirect_to(current_user))
    end

    user_info = JSON.parse(response.body)

    unless user_info['screen_name']
      flash[:notice] = "Twitter authentication failed"
      return(redirect_to(current_user))
    end

    # We have an authorized user, save the information to the database.
    current_user.update_attributes(
                        { :twitter => user_info['screen_name'],
                        :token => @access_token.token,
                        :secret => @access_token.secret })

    flash[:notice] = "Twitter credentials added for #{user_info['screen_name']}!"
    # Redirect to the show page
    redirect_to(@user)
  end

end
