namespace :reports do
  desc 'Generate report data for today'
  task generate_today: :environment do
    puts 'Generating reports for today...'
    ReportGeneratorWorker.perform_async
    puts 'Report generation job enqueued'
  end

  desc 'Generate report data for a specific date'
  task :generate_date, [:date] => :environment do |_t, args|
    date = args[:date] || Date.today.to_s
    puts "Generating reports for #{date}..."
    ReportGeneratorWorker.perform_async(date)
    puts 'Report generation job enqueued'
  end

  desc 'Generate report data for the last N days'
  task :generate_backfill, [:days] => :environment do |_t, args|
    days = (args[:days] || 30).to_i
    puts "Generating reports for the last #{days} days..."

    days.times do |i|
      date = (Date.today - i.days).to_s
      ReportGeneratorWorker.perform_async(date)
    end

    puts "#{days} report generation jobs enqueued"
  end
end
