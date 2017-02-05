class AppliesController < ApplicationController
	def index
		if current_user.admin?
			@applies = Apply.all
		end
	end
	def new
		@apply = Apply.new
		@jobid = params[:format]
		@job = Job.find(@jobid)
		@user = current_user
	end

	def create
		
		@apply = Apply.new(params.require(:apply).permit(:resume, :job_objective, :cover_letter, :synopsis, :education, :experience, :skills, :user_id, :job_id))
		@apply.save
		redirect_to edit_user_registration_path
	end


	def show
		if(current_user.admin? || current_user.id == Apply.find(params[:id]).user_id)
			@apply = Apply.find(params[:id])
			@user = User.find(@apply.user_id)
		else
			redirect_to jobs_path
		end
	end
end