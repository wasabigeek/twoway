require "test_helper"

class SyncedEventTest < ActiveSupport::TestCase
  test "#synchronize" do
    SyncedEvent.new.synchronize
  end
end
