namespace :sync_sources do
  desc "Check for new events in active Syncs"
  task check_for_new_events: :environment do
    Rails.logger = Logger.new(STDOUT) if Rails.env.development?
    # TODO: check if this leads to duplicate sources
    CalendarSource.joins(:syncs).merge(Sync.active).find_each do |source|
      source.check_for_new_events
    end
  end

  desc "Sync saved events in all sources"
  task sync_saved_events: :environment do
    Rails.logger = Logger.new(STDOUT) if Rails.env.development?

    SyncedEventDatum.find_each(&:sync)
  end

end
