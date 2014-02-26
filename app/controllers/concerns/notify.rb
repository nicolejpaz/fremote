module Notify
  def self.new(notification, payload = nil)
    ActiveSupport::Notifications.instrument(notification, payload.to_json)
  end
end