# for scraping
require 'rest-client' 	#http requests
require 'sanitize'		#html sanitization
require 'htmlentities' 	#html decoding

# for inserting to database
require 'active_record'
require 'activerecord-import'
require 'pg'
require 'json'

require 'rails'
require 'paperclip'
require 'aws-sdk'

# for object creation
require_relative '../../app/models/tag.rb'
require_relative '../../app/models/tagging.rb'
require_relative 'models.rb'
require_relative 'scraper_class.rb'

def run_linkedin
	Scraper.connectDatabase
	file = File.read('linkedin_config.json')
	config = JSON.parse file
	linkedIn = Scraper.new "LinkedIn", "Our mission is simple: To create economic opportunity for every member of the global workforce. When you join LinkedIn, you get access to people, jobs, news, updates, and insights that help you be great at what you do."
	total = config["total"]
	searches = config["searches"]
	locations = config["locations"]
	searches.each { |s| s.gsub! " ", "+" }
	searches.each do |search|
		locations.each do |location|
			current = 0
			count = 50
			buffer = 10 + current
			linkedIn.testPath("https://linkedin.com/jobs", :get)
			while(current <= linkedIn.numOfLinks+buffer && current<total)
				# baseLink = "https://www.linkedin.com/jobs/search?keywords=#{search}&locationId=#{location}:0&start=#{current}&count=#{count}&trk=jobs_jserp_pagination_next"
				baseLink = "https://www.linkedin.com/jobs/search?keywords=#{search}&locationId=#{location}:0&orig=JSERP&start=#{current}&count=#{count}"
				linkedIn.getLinks baseLink, :get, /(?<=\"viewJobTextUrl\":\")(.*?)(?=")/
				current = current + count
				puts "current: #{current}  URLs:#{linkedIn.numOfLinks}"
				puts "START SCRAPING."
				buffer = buffer + linkedIn.numOfLinks
				linkedIn.scrapeLinks! Job, {
					:title => /(?<=jobId":[0-9]{9},"title":")(.*?)(?=","page_url)/,
					:description => /(?<={"description":")(.*?)(?=","skillsDescription")/,
					:qualification => /(?<=,"skillsDescription":")(.*?)(?="})/,
					:company_id => /(?<="companyName":")(.*?)(?=",")/,
					:source => :site,
					:location => /(?<=formattedLocation":")(.*?)(?=",")/,
					:tags_for_script => [/(?<=,"formattedJobFunctions":)(.*?\])(?=,"|})/,
												/(?<="formattedIndustries":)(.*?\])(?=,"|})/],
					:country_code => location
				}, {
					:sanitize => [:title, :company_id, :source, :location], # sanitizes values
					:company_description => /(?<=,"companyDescription":")(.*?)(?=")/,
					:logo_remote_url => /(?<=,"logo":")(.*?)(?=")/
				}
			end
		end
	end
end
#  REGEX for getting tags /(?<=formattedIndustries":\[)(.*)(?=\],"derivedLocation)/


# should fix the regex error in first run through with scraper
def fix_company_name(str)
	Scraper.connectDatabase
	Company.all.each do |company|
		ind = company.name.index str
		#if ind!=nil
			p company.name
		#end
	end
end

# updates tags/categories for jobs
def update_tags
	Scraper.connectDatabase
	update = Scraper.new "tag_update"
	j = Job.find(2733)
	update.testPath j.source, :get
	# job_tags = tag_names.collect {|name| Tag.find_or_create_by(name: name)}
	# self.tags = job_tags
end

def fix_job_titles
	Scraper.connectDatabase
	Job.all.each do |job|
		ind = job.title.index "}-->"
		if ind!=nil
			p job.title
		end
	end
end

def find_tags
	Scraper.connectDatabase
	update = Scraper.new "tag_update"
	r = update.testPath "https://www.linkedin.com/jobs/view/134940356?trkInfo=searchKeywordString%3AOil+And+Gas%2CsearchLocationString%3A%2C+%2Cvertical%3Ajobs%2CpageNum%3A1%2Cposition%3A20%2CMSRPsearchId%3A0f64d79a-6821-466d-883a-712b61580da6_1461865048584&refId=0f64d79a-6821-466d-883a-712b61580da6_1461865048584&trk=jobs_jserp_job_listing_text", :get
	puts "Location:!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	puts r.size
	puts r[/(?<=formattedLocation":")(.*?)(?=",")/]
end

#find_tags
run_linkedin
#Scraper.new("Asdf").testPath("https://linkedin.com/jobs", :get)
