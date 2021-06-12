namespace :sync do
  desc "Check for new events in active Syncs"
  task new_events: :environment do
    Rails.logger = Logger.new(STDOUT) if Rails.env.development?
    # TODO: check if this leads to duplicate sources
    Sync.active.find_each do |sync|
      sync.calendar_sources.each(&:check_for_new_events)
    end
  end

  desc "Sync saved events in all sources"
  task synced_events: :environment do
    Rails.logger = Logger.new(STDOUT) if Rails.env.development?

    SyncedEvent.find_each(&:synchronize)
  end

end
