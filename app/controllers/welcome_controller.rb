class WelcomeController < ApplicationController
  def index
  	if user_signed_in?
 		   # redirect_to jobs_path
  	end
  end
  def recruiter
  end
end
