# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery
  
  before_filter :adjust_format_for_iphone

  def iphone_request?
    (request.subdomains.first == "mobile" || params[:format] == "iphone") # || iphone_user_agent? makes it automatically iphone format
  end

  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end

  protected

 def check_bgtwt_layout
  if request.format == :iphone
    return request.xhr? || !params[:no_layout].nil? ? false : "bgtwt"
  end
  return "bgtwt"
 end

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
 
  def adjust_format_for_iphone
    request.format = :iphone if iphone_request?
  end
end
