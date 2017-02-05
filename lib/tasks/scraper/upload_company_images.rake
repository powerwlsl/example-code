namespace :scraper do
  desc 'Upload company images from scraper'
  task :upload_company_images => :environment do
    log = ActiveSupport::Logger.new('log/scraper_upload_company_images.log')
    start_time = Time.now
    companies = Company.where(set_image: false)
    companies.each do |c|
      begin
        if (c.logo_image_url_for_script != nil)
          c.logo_remote_url = c.logo_image_url_for_script
        end
        c.set_image = true
        c.save
      rescue
        log.info "ERROR: #{c.name}:: #{c.logo_image_url_for_script} was not assigned"
      end
    end

    end_time = Time.now
    duration = (end_time-start_time) / 1.second
    log.info "Task finished at #{end_time} and last #{duration} seconds."
    log.close
  end
end
