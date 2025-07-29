namespace :recurring do
  desc "Run fetch products job (for testing)"
  task fetch_products: :environment do
    puts "Running FetchProductsJob..."
    FetchProductsJob.perform_now
    puts "FetchProductsJob completed!"
  end

  desc "Demo mode for interviews (runs every 30 seconds for 2 minutes)"
  task demo: :environment do
    puts "🎯 INTERVIEW DEMO MODE - Automatic Product Refresh"
    puts "This will run every 30 seconds for 2 minutes to show the feature working."
    puts "Press Ctrl+C to stop early."
    puts ""
    
    4.times do |i|
      puts "⏰ [#{Time.current.strftime('%H:%M:%S')}] Run #{i + 1}/4: Refreshing products..."
      FetchProductsJob.perform_now
      puts "✅ Products refreshed successfully!"
      puts "📊 Next refresh in 30 seconds..."
      puts ""
      sleep(30) unless i == 3
    end
    puts "🎉 Demo completed! Automatic refresh is working perfectly!"
  end

  desc "Test automatic refresh (runs every minute for 5 minutes)"
  task test: :environment do
    puts "Starting test mode - FetchProductsJob will run every minute for 5 minutes..."
    puts "Press Ctrl+C to stop early."
    
    5.times do |i|
      puts "\n[#{Time.current}] Run #{i + 1}/5: Running FetchProductsJob..."
      FetchProductsJob.perform_now
      puts "Next run in 1 minute at #{Time.current + 1.minute}"
      sleep(1.minute) unless i == 4
    end
    puts "\nTest completed! Products refreshed 5 times."
  end

  desc "Start recurring jobs in development (runs every hour)"
  task start: :environment do
    puts "Starting recurring jobs in development mode..."
    puts "This will run FetchProductsJob every hour."
    puts "Press Ctrl+C to stop."
    
    loop do
      puts "\n[#{Time.current}] Running FetchProductsJob..."
      FetchProductsJob.perform_now
      puts "Next run in 1 hour at #{Time.current + 1.hour}"
      sleep(1.hour)
    end
  end
end