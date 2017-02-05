# Copy paste this script into rails console on heroku
Company.all.sort.reverse_each do |c|
  begin
    if (c.logo_remote_url == nil and c.logo_image_url_for_script != nil)
      c.logo_remote_url = c.logo_image_url_for_script
      c.save
    end
  rescue
    puts c.logo_image_url_for_script
  end
end

# Creates tagging relationships
Job.all.sort.reverse_each do |j|
  if j.tag_list == ""
    j.tag_list = j.tags_for_script
    j.save
  end
end
