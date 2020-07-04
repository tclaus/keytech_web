# frozen_string_literal: true

require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new

scheduler.cron '5 0 * * *' do
  # Homecleaning Tasks every day, five minutes after midnight
  # (see "man 5 crontab" in your terminal)
  RemoveUnconfirmedAccountsJob.perform_now
end
