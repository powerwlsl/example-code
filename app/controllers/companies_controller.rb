class CompaniesController < ApplicationController
  include ApplicationHelper
  before_action :require_admin, :only => [:new, :update, :create, :edit]
  def index
		# join returns all companies with jobs, group return single company object for each id
    # counts the number of jobs per id and orders company objects in descending
    @companies = Company.joins(:jobs).group("companies.id").order("count(companies.id) DESC")
		@companies = @companies.paginate(:page => params[:page], :per_page => 10)
	end

	def new
		@company = Company.new
	end

	def create
		@company = Company.new(company_params)
		@company.save
		redirect_to company_path(@company)
	end

	def edit
		@company = Company.find(params[:id])
	end

	def show
		@company = Company.find(params[:id])
		@jobs = @company.jobs.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
		# @paginate = true
	end

	#Update refers to the SQL operation
	def update
		@company = Company.find(params[:id])
		@company.update(company_params)
		redirect_to company_path(@company)
	end

	def company_params
		params.require(:company).permit(:name,:description,:link, :logo_remote_url, :logo)
	end
end
