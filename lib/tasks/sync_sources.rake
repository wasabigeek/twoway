namespace :sync_sources do
  desc "Retrieves events (only changes where possible) from active Syncs for processing"
  task pull_changes: :environment do
    # TODO: check if this leads to duplicate sources
    CalendarSource.joins(:syncs).merge(Sync.active).find_each do |source|
      source.event_changes.each do |event_change|
        snapshot = CalendarEventSnapshot.find_or_initialize_by(
          external_id: event_change.id,
          snapshot_at: event_change.updated_at,
          calendar_source: source
        )
        snapshot.update!(
          name: event_change.title,
          starts_at: event_change.starts_at,
          ends_at: event_change.ends_at
        )
        # snapshot.queue (maybe do it in after_commit for now)
      end
    end
  end

end
