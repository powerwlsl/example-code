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

# interface calls to specific site like Scraper::Linkedin < Scraper::Base
# interface chooses what do to with the list of records
class Scraper
	attr_accessor :sleep_time
	LINKEDIN_HEADERS = {
		user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0',
		accept_encoding: 'gzip, deflate, br',
		accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
		refer: 'https://www.linkedin.com',
		accept_language: 'en-US,en;q=0.5'
	}

	def initialize(name, description = "")
		@urls = []
		@sleep_time = 4
		@source = name
		@description = description
		@user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
		# http://stackoverflow.com/questions/27231113/999-error-code-on-head-request-to-linkedin
		RestClient.proxy = ENV['SCRAPER_PROXY']
	end

  def testPath(path, restMethod, options = {})
      options[:user_agent] = @user_agent
      response = RestClient.method(restMethod).call path, LINKEDIN_HEADERS
			puts "-------------REQUEST-------------"
			puts response.request.inspect
			puts response.request.args
			puts "--------------CODE---------------"
			puts response.code
			puts "--------RESPONSE HEADERS---------"
			puts response.headers
			puts "--------------BODY---------------"
			puts response.body
			puts "------------COOKIES--------------"
			puts response.cookies
			return response.body
  end

	def numOfLinks
		return @urls.length
	end

	def self.connectDatabase(cmd = 'cd ../../; heroku pg:credentials DATABASE --app petro-recruit')
		# CONNECT TO HEROKU-HOSTED DATABASE
		begin
			# will work assuming script is run from 2 file directories deep from root
			value = `#{cmd}` # returns the output of your command
			username = /user=.+?\s(?=)/.match(value).length != nil ? /user=.+?\s(?=)/.match(value)[0].gsub(/user=/, "").gsub(/\s/, "") : ''
			password = /password=.+?\s(?=)/.match(value).length != nil ? /password=.+?\s(?=)/.match(value)[0].gsub(/password=/, "").gsub(/\s/, "") : ''
			database = /dbname=.+?\s(?=)/.match(value).length != nil ? /dbname=.+?\s(?=)/.match(value)[0].gsub(/dbname=/, "").gsub(/\s/, "") : ''
			host = /host=.+?\s(?=)/.match(value).length != nil ? /host=.+?\s(?=)/.match(value)[0].gsub(/host=/, "").gsub(/\s/, "") : ''
			puts "Using the following parameters fetched from heroku toolbelt:
			-------------------------------------------
			host: #{host}
			username: #{username}
			password: #{password}
			database: #{database}
			-------------------------------------------"
		rescue
			# catches any exceptions from the automated method.
			puts "Could not execute command '$ #{cmd}"
			puts "Make sure heroku toolbelt is installed and you are logged into heroku."
			puts "Also be sure that the script is running from '/db/scripts/'"
			database = 'd24u9149iv9vp6'
			host = "ec2-54-83-53-120.compute-1.amazonaws.com"
			puts "Input the database username: (in root directory, run '$ heroku pg:credentials DATABASE')"
			username = gets
			puts "Input the database password:"
			password = gets
		end

		# connect to database,
		# run heroku pg:credentials in root to get info
		ActiveRecord::Base.establish_connection(
			:adapter => 'postgresql',
			:host => host,
			:username => username,
			:password => password,
			:database => database
		)
		puts "Connection to #{database} Established"
	end


	# string path, symbol method, regex for link, hash of options to pass to REST
	def getLinks(path, restMethod, linkRegex, options = {})
		options[:user_agent] = @user_agent
		response = RestClient.method(restMethod).call(path, LINKEDIN_HEADERS).body # fetch base URL and get all links that match the regex
		puts response
		urls = response.scan(linkRegex).map { |arr| arr.join "" } # scan returns an array of all matched groups.
		puts "#{path}."
		urls.each { |link| @urls << CGI::unescapeHTML(link) }
	end


	# pass a hash with each primary key and its regex for finding it on the page or its value
	def scrapeLinks!(obj, primary_keys = {}, options = {:sanitize=>[]})
    dict = File.read('dictionary.json')
    dict = JSON.parse(dict)
    # remove duplicate links
		@urls = @urls.uniq
		insertions = []
		while(@urls.length>0)
			url = @urls.pop(1)[0] # fetches and deletes last element
			options[:user_agent] = @user_agent
      insertion = scrapeJobCreateCompany obj, primary_keys, url, dict, options
      insertions << insertion if insertion != nil
			sleep @sleep_time - (@sleep_time/4) + Random.new.rand(@sleep_time/2) # to prevent ip blocking
		end
		obj.import insertions	# adds new ActiveRecord objects to database
	end


	private
  def scrapeJobCreateCompany(obj, primary_keys, url, dict, options = {})
		page = begin
    		RestClient.get(url, LINKEDIN_HEADERS).body
		rescue => error
				puts error.backtrace
				nil
    end
    if page.nil?
        puts "#{url} was rejected."
        return nil
    end
    page.gsub! "\\", "" # cleans up double nested json escape characters
    objHash = {}

    # Fetch attributes to be added
    primary_keys.each do |key, val| # key is field, val is regex
      if (val.is_a? Regexp) # if regex is passed, evaluate
        objHash[key] = page[val]
				if objHash[key].is_a?(String)
					objHash[key].gsub!("u003e", ">")
					objHash[key].gsub!("u003c", "<")
				end
				puts "Location: #{objHash[key]}" if key == :location
			elsif (val.is_a? Array) # assume list of regex
        objHash[key] = []
        val.each do |reg|
          job_categories = page[reg]
          objHash[key] << JSON.parse(job_categories) if job_categories != nil
        end
        # using dictionary, rename categories
				objHash[key].flatten!
				objHash[key].map! do |category|
					replace =  dict[category]
          category = replace unless (replace == nil or replace == "REMOVE")
        end
        objHash[key] = objHash[key].flatten.uniq
				objHash[key].delete ""
				objHash[key] = objHash[key].join ", " # send as tag_list
				objHash[key] = "other" if (objHash[key] == "" or objHash[key] == nil)
			elsif val == :site # if symbol :site is pased, return url
        objHash[key] = url
      else # otherwise, return value in the passed hash
        objHash[key] = val
      end

      # sanitize if in the sanitize key list
      if options[:sanitize].index(key)
        objHash[key] = HTMLEntities.new.decode(Sanitize.fragment objHash[key])
      end

      # create or find the proper company and return its id
      if(key == :company_id)
        # regexp finds name, this converts name to company_id
        desc = ""
        if options.has_key?(:company_description)
          desc = page[options[:company_description]]
        end
        logo = ""
        if options.has_key?(:logo_remote_url)
          logo = page[options[:logo_remote_url]]
        end
        objHash[key] = fetch_company_id(objHash[key], desc, logo)
      end

			# If mistake in scraping json
			if (objHash[key].is_a? String)
				objHash[key] = objHash[key][0...(objHash[key].index("\"}"))] if objHash[key].index("\"}") != nil
			end
    end
    # TROUBLESHOOTER return any nil values from scraping
    objHash.each do |key, val|
      (puts "#{key} is: |#{val}| FOR URL:#{url}" if (not val and key != :qualification)) # if val is nil
      puts "#title: {key.length}" if key.length > 200
    end

		# add location information to obj
		objHash[:continent] = JSON.parse(File.read("linkedin_country_codes.json"))[objHash[:country_code].upcase]

		insertion = obj.new(objHash)
    puts insertion.title
		puts insertion.source
    return insertion
  end

  def fetch_company_id(name, desc = "", logo = "")
		if desc != nil
			desc.gsub!("u003e", ">")
			desc.gsub!("u003c", "<")
		end
		if name != nil
			return Company.create_with(description: desc, logo_image_url_for_script: logo).find_or_create_by(name: name).id
		else
			return Company.create_with(description: @description).find_or_create_by(name: @source).id
		end
	end

end
