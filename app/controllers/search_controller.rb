class SearchController < ApplicationController
	def search
	  if params[:q].nil?
	    @jobs = []
	  else
	    @jobs = Job.search params[:q]
	  end
	end
end
