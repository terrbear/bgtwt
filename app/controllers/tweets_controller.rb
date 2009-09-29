class TweetsController < ApplicationController
  layout :check_bgtwt_layout, :except => [:edit, :updates, :recent_feed, :user_feed, :ms_feed, :user_recents, :grab_shakers]

  before_filter :validates_tweet_ownership, 
    :only => [:edit, :update]

  before_filter :admin_required, :only => [:stick, :unstick, :delete]

  caches_page :firehose
  caches_page :index, :if => Proc.new{|c| c.send(:flash)[:notice].blank? && c.request.format.html? && !c.iphone_request?}
  caches_page :show, :if => Proc.new{|c| c.send(:flash)[:notice].blank? && c.request.format.html? && !c.iphone_request?}

  def index
    @tweet = Tweet.new
  end

  def preview
    @text = params[:data]
    render(:layout => false)
  end

  #for gay iphone
  def edit_tweet
    @tweet = Tweet.new
  end
  #/for gay iphone
  
  #menu widgets
  def stickies
    @stickies = Tweet.stickies
    render(:layout => false)
  end

  def shakers
    @shakers = Tweet.shakers
    render(:layout => false)
  end

  def recents
    @recents = Tweet.public.parents.recent(10)
    render(:layout => false)
  end

  def recent_feed
    @tweets =  Tweet.public.parents.recent(10)
      logger.warn("Found recent tweets: #{@tweets.size}")
    @more = false
    if !@tweets.nil? && @tweets.size >= 10
      @tweets.delete_at(@tweets.size-1)
      @more = true
      @max=9
      logger.warn("Setting more to true")
    end
    respond_to do |format|
      format.xml
      format.iphone
    end
  end

  def firehose_feed
    session[:firehose] ||= Time.now.utc
    @tweets = Tweet.public.find(:all, :conditions => ["created_at > ?", session[:firehose]])
    if @tweets.empty?
      render(:nothing => true, :status => 400, :layout => false)
    else
      session[:firehose] = Time.now.utc
      render(:partial => "firehose_feed", :locals => {:tweets => @tweets})
    end
  end

  def recent_feed_more
    @max = params[:max].to_i if (params[:max].to_i rescue false)
    @max = (@max.nil? || @max > 25 || @max <= 0) ? 25 : @max
    
    @current = params[:current].to_i if (params[:current].to_i rescue false)
    @current = (@current.nil? || @current < 0) ? 0 : @current
    @less = @current > 0
    @tweets =  Tweet.public.parents.find(:all, :order => 'created_at desc', :limit => @max+1, :offset => @current)
    @more=false
    if !@tweets.nil? && @tweets.size > @max
      @tweets.delete_at(@tweets.size-1)
      @more=true
    end
    respond_to do |format|
      format.iphone
    end
  end

  def user_feed
    @user = User.find(params[:id])
    @tweets = @user.tweets.parents.find(:all, :limit => 15)
    respond_to do |format|
      format.xml
      format.iphone
    end
  end

  def ms_feed
    @tweets = Tweet.shakers
    respond_to do |format|
      format.xml
      format.iphone
    end
  end

  def stick
    tweet = Tweet.find(params[:id])
    tweet.stick!
    expire_page("/" + tweet.root_code)
    flash[:notice] = "Post stickied"
    redirect_to(:action => :show, :id => tweet.code)
  end

  def unstick
    tweet = Tweet.find(params[:id])
    tweet.unstick!
    expire_page("/" + tweet.root_code)
    flash[:notice] = "Post unstickied"
    redirect_to(:action => :show, :id => tweet.code)
  end

  def search
    @search_string = params[:search]
    @tweets = Tweet.search(@search_string)
    if @tweets.empty?
      flash[:notice] = "No results found for #{@search_string}"
      return(redirect_to :action => :index)
    end
  end

  def edit
    @tweet = Tweet.find(params[:id])
  end

  #[terry] The idea here is that we'll use the
  #id and page rendered time (coming in from params[:viewed])
  #to make a unique key for each show page. That way, even if someone
  #loads the same bgtwt twice, they'll have unique updates going.
  #
  #The timestamp (:viewed) is nice because it also serves
  #as the first limit for reply queries.
  def updates
    key = "#{params[:id]}.#{params[:viewed]}"
    session[key] ||= Time.parse(params[:viewed])
    @replies = Tweet.find(params[:id]).
                      replies.
                      ignore_user(current_user).
                      find(:all, :conditions => ["created_at > ?", session[key]])
    if @replies.empty?
      render :nothing => true, :status => 400
    else
      session[key] = Time.now.utc
      render(:partial => "tweets/replies", :locals => {:replies => @replies, :growl => true})
    end
  end

  def update
    @tweet = Tweet.find(params[:id])
    @tweet.update_attributes(params[:tweet])
    flash[:notice] = "Tweet updated!"
    expire_page("/" + @tweet.root_code)
    if @tweet.reply?
      redirect_to :action => :show, :id => @tweet.parent.code, :format => :html
    else
      redirect_to :action => :show, :id => @tweet.code, :format => :html
    end
  end

  def show
    @tweet = Tweet.parents.find_by_code(params[:id] || params[:code]) 
    @replies = @tweet.replies
    @reply = Tweet.new(:parent => @tweet, :author => current_user)
    respond_to do |wants|
      wants.html { render }
      wants.text { render(:text => @tweet.body) }
      wants.xml 
      wants.iphone { render }
    end
  rescue
    logger.error{"Error showing tweet: #{$!}"}
    flash[:notice] = "Couldn't find a tweet with that ID"
    redirect_to(:action => :index)
  end

  def create
    #honeypot spam
    redirect_to(:action => :index) unless params['x-email'].blank?

    t = Tweet.create!(params[:tweet].merge(:author => current_user, :secret => ((params[:commit] == "Post Privately") || !logged_in?)))
    flash[:notice] = "Whoah! That's a big tweet!"
    respond_to do |wants|
      wants.html { redirect_to(t.permalink) }
      wants.text { render(:text => t.permalink) }
      wants.iphone { redirect_to(t.permalink(request.host_with_port)) }
    end
  rescue
    logger.error("Error creating tweet: #{$!.to_s}")
    redirect_to(:action => :index)
  end

  def edit_reply
    begin
      @tweet = Tweet.find(params[:id])
      @reply = Tweet.new(:parent => @tweet, :author => current_user)
    rescue
      logger.error{"Error editing a reply: #{$!}"}
      flash[:notice]  = "Trying to reply to a non-existent bgtwt."
    end
  end

  def reply
    #honeypot spam
    redirect_to(:action => :index) unless params['x-email'].blank?

    t = Tweet.create!(params[:tweet].merge(:parent_id => params[:parent_id], :author => current_user))
    expire_page("/" + t.root_code)
    return render(:partial => "replies", :locals => {:replies => [t]})
  end

  def delete
    t = Tweet.find(params[:id])
    t.destroy
    expire_page("/" + t.root_code)
    flash[:notice] = "Tweet deleted."
    redirect_to(:action => :index)
  end

  protected
  def validates_tweet_ownership
    unless Tweet.find(params[:id]).editable?(current_user)
      flash[:notice] = "You can't edit that tweet."
      return redirect_to(:action => :index)
    end
  end
end
