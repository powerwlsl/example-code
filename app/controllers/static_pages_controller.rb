class StaticPagesController < ApplicationController
  include ApplicationHelper
  before_action :require_admin, :only => [:adminpanel]
  def adminpanel
    # before_filter :autenticate_user!
    # before_filter do
    #   # redirect if not admin or not logged in
    #   redirect_to :new_user_session_path unless current_user && current_user.admin?
    # end

    @users_count = User.count
    @job_count = Job.count
    @company_count = Company.count
    @users = User.all
    @users_with_resumes = @users.select { |u| u.resume.url != "/resumes/original/missing.png" and u.resume.url != nil }
    @resume_count = @users_with_resumes.size
  end

  def faq
    @jobs = Job.all
    render :layout => false

  end

  def about
  end

  def feedback
  end

  def press
  end

  def howitworks
  end

  def careers
  end

  def product
  end
end
