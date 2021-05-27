class SyncSource < ApplicationRecord
  belongs_to :sync
  belongs_to :calendar_source
end
