namespace :sidekiq do
  desc "Start Sidekiq with recurring jobs"
  task start: :environment do
    require 'sidekiq'
    require 'sidekiq-scheduler'
    
    puts "Starting Sidekiq with recurring jobs..."
    system("bundle exec sidekiq -r ./config/sidekiq.rb")
  end
end