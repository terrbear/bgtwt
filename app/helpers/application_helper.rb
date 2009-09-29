# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
end
