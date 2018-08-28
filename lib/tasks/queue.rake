namespace :eefio do
  namespace :queue do
    desc 'Deletes all jobs in the default job queue'
    task clear: :environment do
      require 'sidekiq/api'

      puts
      puts '==> Clearing Default job queue'
      Sidekiq::Queue.new('default').clear
      puts '==> Clearing Default job queue… done'
      puts

      puts '==> Clearing RetrySet job queue'
      Sidekiq::RetrySet.new.clear
      puts '==> Clearing RetrySet job queue… done'
      puts

      puts '==> Clearing ScheduledSet job queue'
      Sidekiq::ScheduledSet.new.clear
      puts '==> Clearing ScheduledSet job queue… done'
      puts
    end
  end
end
