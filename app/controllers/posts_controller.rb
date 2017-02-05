class PostsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!

  # def show
  #   @job = Job.find(params[:id])
  #   @apply_link
  #   if user_signed_in?
  #     @apply_link = new_apply_path(@job)
  #   else
  #     @apply_link = new_user_session_path
  #   end
  # end

  def new
    @post = current_user.posts.new
  end

  # def edit
  #   @job = Job.find(params[:id])
  # end

  # def update
  #   @job = Job.find(params[:id])
  #   @job.update(job_params)
  #   @job =  Job.find(params[:id])
  #   if params[:index]
  #     if @job.tag_list == job_params[:tag_list]
  #       flash[:success] = "Assigned Category '#{@job.tag_list}'"
  #     else
  #       flash[:error] = "Error. Did not assign category."
  #     end
  #     redirect_to "/category?index=#{params[:index]}"
  #   else
  #     redirect_to job_path(@job)
  #   end
  # end

  # def create
  #   @job = Job.new(job_params)
  #   @job.save
  #   #if generated, show new, else go back to form
  #   # note this part should be reworked with flash
  #   if(not(@job.new_record?))
  #     redirect_to job_path(@job)
  #   #else
  #   # redirect_to new_job_path
  #   end
  # end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post
    else
      render 'new'
    end
  end

  # def category
  #   if params[:index]
  #     @index = params[:index].to_i
  #   end
  #   @index ||= 0
  #   if @index >= Job.count
  #     redirect_to '/youredone'
  #   end
  #   @job = Job.all[@index]
  # end

  # private
  # def job_params
  #   params.require(:job).permit(:title, :description, :qualification, :company_id, :tag_list)
  # end
  private
    def post_params
      params.require(:post).permit(:title, :description)
    end
end
