namespace :sync_sources do
  desc "Retrieves events (only changes where possible) from active Syncs for processing"
  task pull_changes: :environment do
    Rails.logger = Logger.new(STDOUT)
    # TODO: check if this leads to duplicate sources
    CalendarSource.joins(:syncs).merge(Sync.active).find_each do |source|
      source.event_changes.each do |event_change|
        puts event_change
        snapshot = CalendarEventSnapshot.find_or_initialize_by(
          external_id: event_change.id,
          calendar_source: source,
          # TODO: use a hash of properties instead
          name: event_change.title,
          starts_at: event_change.starts_at,
          ends_at: event_change.ends_at
        )

        unless snapshot.persisted?
          puts 'Creating New Snapshot.'
          snapshot.update!(snapshot_at: event_change.updated_at)
          # after_commit triggered in CalendarEventSnapshot
        end
      end
    end
  end

end
