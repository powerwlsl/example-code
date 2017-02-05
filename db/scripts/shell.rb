# for scraping
require 'rest-client' 	#http requests
require 'sanitize'		#html sanitization
require 'htmlentities' 	#html decoding

# required classes to build objects for insertion
class Job < ActiveRecord::Base
	belongs_to :company
	has_many :applies
	validates :title, presence: true
	has_many :location_relationship
end

class Company < ActiveRecord::Base
	has_many :jobs
	validates :name, uniqueness: true, presence: true
end

class Scraper
	attr_accessor :SLEEP_TIME
	@urls = []
	@SLEEP_TIME = 0.75

	# string path, symbol method, regex for link, hash of options to pass to REST
	def getLinks(path, restMethod, linkRegex, options = {})
		# fetch base URL and get all links that match the regex
		response = RestClient.method(restMethod).call site, options
		urls = response.scan(linkRegex)
		puts "Found #{urls.length} links from #{path}."
		urls.each { |link| @urls << CGI::unescapeHTML(link)}
	end

	# pass a hash with each primary key and its regex for finding it on the page
	def scrapeLinks!(obj, primary_keys = {})
		insertions = []
		while(@urls.length>0)
			url = @urls.pop(1)[0] # fetches and deletes last element
			page = RestClient.get url
			objHash = {}
			primary_keys.each do |key, regex|
				objHash[key] = Sanitize:CSS.stylesheet(page[regex], Sanitize::Config::BASIC)
			end
			insertions << obj.new(objHash)
		end
	end
end

def shell_crawler()
	# CRAWLER, gets links and builds list urls
	urls = []
	file = File.new("shell.html", "r")
	# fetch links
	while (line = file.gets)
		obj = line.scan(/https:\/\/krb-sjobs\.brassring\.com\/tgwebhost\/jobdetails.+?(?=")/i)
		if(obj.size>0)
			urls << obj[0].gsub!("amp;", "")
		end
	end
	puts"Found #{urls.size} Links"
	file.close
	return urls
end

def shell_scraper(urls)
	# SCRAPER, checks links for content, builds objects
	inserts = []
	shell_id = Company.find_or_create_by(name: "Shell").id;
	puts "Company Shell id: #{shell_id}"

	# iterate through webpages
	urls.each do |site|
		response = RestClient.get site

		title_array = response.scan(/id='Job Title' >.+?(?=<\/span>)/i)
		if(title_array.size > 0)
			title = Sanitize.fragment(title_array[0].gsub!("id='Job Title' >", "") , Sanitize::Config::BASIC)
			Sanitize::CSS.stylesheet(title, Sanitize::Config::BASIC)
		else
			title = nil
		end

		description_array = response.scan(/id='Job Description' >.+?(?=<\/span><\/td>)/i)
		if(description_array.size > 0)
			description = Sanitize.fragment( description_array[0].gsub!("id='Job Description' >", ""), Sanitize::Config::BASIC)
			Sanitize::CSS.stylesheet(description, Sanitize::Config::BASIC)
		else
			description = nil
		end

		requirements_array = response.scan(/id='Requirements' >.+?(?=<\/span><\/td>)/i)
		if(requirements_array.size>0)
			requirements = Sanitize.fragment( requirements_array[0].gsub("id='Requirements' >", ""), Sanitize::Config::BASIC)
			Sanitize::CSS.stylesheet(requirements, Sanitize::Config::BASIC)
		else
			requirements = nil
		end

		location_array = response.scan(/id='Work Location' >.+?(?=<\/span>)/i)
		location_array2 = response.scan(/id='Country of Work Location' >.+?(?=<\/span>)/i)
		location_array = location_array + location_array2
		if(location_array.size == 1)
			location = Sanitize.fragment(location_array[0].gsub("id='Work Location' >", "").gsub("id='Country of Work Location' >", "") , Sanitize::Config::BASIC)
			Sanitize::CSS.stylesheet(location, Sanitize::Config::BASIC)
		elsif(location_array.size == 2 )
			location = Sanitize.fragment(location_array[0].gsub("id='Work Location' >", "") + ", " + location_array[1].gsub("id='Country of Work Location' >", ""), Sanitize::Config::BASIC)
			Sanitize::CSS.stylesheet(location, Sanitize::Config::BASIC)
		else
			location = nil
		end

		# builds list of Jobs to insert
		inserts << Job.new(
			:title => title,
			:description => (HTMLEntities.new.decode description),
			:qualification => (HTMLEntities.new.decode requirements),
			:company_id => shell_id,
			:source => site,
			:location => location
		)
		#puts "Title: #{title}\nDescription: #{description} \nRequirements: #{requirements} \nLocation: #{location} \nSource: #{site}"
		puts "#{inserts}"
		sleep(1)  # to stop ip from being blocked
	end
	return inserts
end
