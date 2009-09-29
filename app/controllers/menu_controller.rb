class MenuController < ApplicationController
  def actions
  end

  def permissions
    if logged_in?
      if current_user.admin?
        return render(:text => "'admin'")
      else
        return render(:text => current_user.id)
      end
    else
      return render(:nothing => true)
    end
  end

  def is_anonymous
    render(:text => (!logged_in?).to_s)
  end
end
