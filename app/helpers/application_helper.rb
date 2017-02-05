module ApplicationHelper
  def admin?
    self.admin == true
  end

  def require_admin
    unless current_user && current_user.admin?
      flash[:error] = "You must be an admin to access this."
      redirect_to new_user_session_path
    end
  end
end
