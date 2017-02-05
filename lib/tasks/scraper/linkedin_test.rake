require 'rest-client' 	#http requests
task :linkedin_test => :environment do
  STDOUT.sync = true
  puts RestClient.method(:get).call "https://www.linkedin.com/jobs/view/134940356?trkInfo=searchKeywordString%3AOil+And+Gas%2CsearchLocationString%3A%2C+%2Cvertical%3Ajobs%2CpageNum%3A1%2Cposition%3A20%2CMSRPsearchId%3A0f64d79a-6821-466d-883a-712b61580da6_1461865048584&refId=0f64d79a-6821-466d-883a-712b61580da6_1461865048584&trk=jobs_jserp_job_listing_text" # fetch base URL and get all links that match the regex
end
