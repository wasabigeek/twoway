namespace :sync_sources do
  desc "Retrieves events (only changes where possible) from active Syncs for processing"
  task pull_changes: :environment do
    # TODO: check if this leads to duplicate sources
    CalendarSource.joins(:syncs).merge(Sync.active).find_each do |source|
      source.event_changes.each do |event_change|
        # event_change = EventChange.find_or_create_by!(event_change.last_modified, event_change.name, event_change.id, event_change.starts_at, event_change.ends_at)
        # event_change.queue (maybe do it in after_commit for now)
      end
    end
  end

end
