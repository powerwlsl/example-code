class RegistrationsController < Devise::RegistrationsController

  def update
  	@current_user = User.find(current_user.id)
  	if @current_user.update(information_update_params)
      flash[:success] = "Your information was updated!"
      if session[:job_redirect].is_a? Integer
        redirect_id = session[:job_redirect]
        session.delete :job_redirect
        redirect_to job_path(redirect_id)
      else
        redirect_to root_path
      end
    else
      flash[:error] = "Your information was not saved. #{information_update_params}"
      redirect_to edit_user_registration_path
    end
  end

  def edit_password
  end


  protected

  def after_sign_up_path_for(resource)
    "/users/edit" # Or :prefix_to_your_route
  end


  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :mobile_number, :city, :country, :postal_code, :synopsis, :year_in_industry, :education, :experience, :skills, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit( :email, :password, :password_confirmation, :current_password)
  end
  def information_update_params
  	params.require(:user).permit(:first_name, :last_name, :phone_number, :resume)
  end


end
