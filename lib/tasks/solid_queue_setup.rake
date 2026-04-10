namespace :solid_queue do
  desc "Create solid_queue tables if they don't exist"
  task setup: :environment do
    unless ActiveRecord::Base.connection.table_exists?("solid_queue_jobs")
      puts "Creating solid_queue tables..."
      load Rails.root.join("db/queue_schema.rb")
      puts "solid_queue tables created!"
    else
      puts "solid_queue tables already exist, skipping."
    end
  end
end